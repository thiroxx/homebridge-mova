import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var nearbyStores: [NearbyStore] = []
    @Published var activeReminders: [LocationReminder] = []
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    // Predefined store types
    let storeTypes = [
        "Supermarkt": ["REWE", "EDEKA", "Aldi", "Lidl", "Kaufland", "Netto"],
        "Apotheke": ["Apotheke"],
        "Post": ["Post", "DHL", "Postfiliale"],
        "Drogerie": ["dm", "Rossmann", "Müller"],
        "Baumarkt": ["Obi", "Bauhaus", "Hornbach", "toom"]
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100 // Update alle 100m
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        guard authorizationStatus == .authorizedWhenInUse || 
              authorizationStatus == .authorizedAlways else {
            requestAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Geo-Fencing
    
    func setupGeofence(for store: NearbyStore, radius: CLLocationDistance = 200) {
        let region = CLCircularRegion(
            center: store.coordinate,
            radius: radius,
            identifier: store.id
        )
        
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        locationManager.startMonitoring(for: region)
        
        print("🗺️ Geofence aktiviert: \(store.name) (\(radius)m)")
    }
    
    func removeGeofence(identifier: String) {
        locationManager.monitoredRegions
            .first(where: { $0.identifier == identifier })
            .map { locationManager.stopMonitoring(for: $0) }
    }
    
    func removeAllGeofences() {
        locationManager.monitoredRegions.forEach { region in
            locationManager.stopMonitoring(for: region)
        }
    }
    
    // MARK: - Nearby Stores
    
    func searchNearbyStores(shoppingItems: [ShoppingItem]) async {
        guard let location = currentLocation else { return }
        
        let categories = determineCategories(from: shoppingItems)
        var foundStores: [NearbyStore] = []
        
        for category in categories {
            let stores = await searchStores(
                ofType: category,
                near: location,
                radius: 2000 // 2km Radius
            )
            foundStores.append(contentsOf: stores)
        }
        
        // Sortiere nach Entfernung
        foundStores.sort { store1, store2 in
            let dist1 = location.distance(from: CLLocation(
                latitude: store1.coordinate.latitude,
                longitude: store1.coordinate.longitude
            ))
            let dist2 = location.distance(from: CLLocation(
                latitude: store2.coordinate.latitude,
                longitude: store2.coordinate.longitude
            ))
            return dist1 < dist2
        }
        
        await MainActor.run {
            self.nearbyStores = Array(foundStores.prefix(10))
            
            // Setup Geofences für die nächsten 5 Stores
            foundStores.prefix(5).forEach { store in
                setupGeofence(for: store)
            }
        }
    }
    
    private func searchStores(ofType type: String, near location: CLLocation, radius: CLLocationDistance) async -> [NearbyStore] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = type
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radius * 2,
            longitudinalMeters: radius * 2
        )
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            return response.mapItems.compactMap { item -> NearbyStore? in
                guard let name = item.name,
                      let location = item.placemark.location else {
                    return nil
                }
                
                let distance = location.distance(from: location)
                
                return NearbyStore(
                    id: item.placemark.coordinate.description,
                    name: name,
                    type: type,
                    coordinate: item.placemark.coordinate,
                    address: formatAddress(item.placemark),
                    distance: distance
                )
            }
        } catch {
            print("❌ Store search failed: \(error)")
            return []
        }
    }
    
    private func determineCategories(from items: [ShoppingItem]) -> [String] {
        var categories = Set<String>()
        
        for item in items where !item.isPurchased {
            switch item.category {
            case .groceries:
                categories.insert("Supermarkt")
            case .personal:
                categories.insert("Drogerie")
                categories.insert("Apotheke")
            case .household:
                categories.insert("Baumarkt")
                categories.insert("Drogerie")
            case .other:
                categories.insert("Supermarkt")
            }
        }
        
        return Array(categories)
    }
    
    private func formatAddress(_ placemark: CLPlacemark) -> String {
        var parts: [String] = []
        
        if let street = placemark.thoroughfare {
            parts.append(street)
        }
        if let number = placemark.subThoroughfare {
            parts.append(number)
        }
        if let city = placemark.locality {
            parts.append(city)
        }
        
        return parts.joined(separator: ", ")
    }
    
    // MARK: - Smart Routing
    
    func calculateOptimalRoute(stores: [NearbyStore]) -> [NearbyStore] {
        guard let currentLocation = currentLocation else { return stores }
        
        // Einfacher Nearest-Neighbor Algorithmus
        var route: [NearbyStore] = []
        var remaining = stores
        var current = currentLocation.coordinate
        
        while !remaining.isEmpty {
            // Finde nächsten Store
            let (index, _) = remaining.enumerated().min(by: { store1, store2 in
                let dist1 = distanceBetween(current, store1.element.coordinate)
                let dist2 = distanceBetween(current, store2.element.coordinate)
                return dist1 < dist2
            })!
            
            let nextStore = remaining.remove(at: index)
            route.append(nextStore)
            current = nextStore.coordinate
        }
        
        return route
    }
    
    private func distanceBetween(_ coord1: CLLocationCoordinate2D, _ coord2: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let loc2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return loc1.distance(from: loc2)
    }
    
    // MARK: - Location Reminders
    
    func createLocationReminder(for store: NearbyStore, items: [ShoppingItem]) {
        let reminder = LocationReminder(
            id: UUID().uuidString,
            storeName: store.name,
            storeId: store.id,
            coordinate: store.coordinate,
            items: items,
            isActive: true
        )
        
        activeReminders.append(reminder)
        setupGeofence(for: store)
    }
    
    func removeLocationReminder(id: String) {
        if let index = activeReminders.firstIndex(where: { $0.id == id }) {
            let reminder = activeReminders.remove(at: index)
            removeGeofence(identifier: reminder.storeId)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || 
           authorizationStatus == .authorizedAlways {
            startTracking()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let reminder = activeReminders.first(where: { $0.storeId == region.identifier }) else {
            return
        }
        
        // Sende Benachrichtigung
        NotificationManager.shared.scheduleLocationReminderNotification(
            storeName: reminder.storeName,
            itemCount: reminder.items.count
        )
        
        print("📍 Eingetreten in Geofence: \(reminder.storeName)")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("📍 Verlassen: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("❌ Geofence monitoring failed: \(error.localizedDescription)")
    }
}

// MARK: - Models

struct NearbyStore: Identifiable, Codable {
    let id: String
    let name: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    let address: String
    let distance: CLLocationDistance
    
    var distanceFormatted: String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            return String(format: "%.1fkm", distance / 1000)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, address, distance
        case latitude, longitude
    }
    
    init(id: String, name: String, type: String, coordinate: CLLocationCoordinate2D, address: String, distance: CLLocationDistance) {
        self.id = id
        self.name = name
        self.type = type
        self.coordinate = coordinate
        self.address = address
        self.distance = distance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        address = try container.decode(String.self, forKey: .address)
        distance = try container.decode(CLLocationDistance.self, forKey: .distance)
        
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(address, forKey: .address)
        try container.encode(distance, forKey: .distance)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
}

struct LocationReminder: Identifiable {
    let id: String
    let storeName: String
    let storeId: String
    let coordinate: CLLocationCoordinate2D
    let items: [ShoppingItem]
    var isActive: Bool
}

// MARK: - CLLocationCoordinate2D Codable Extension

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}
