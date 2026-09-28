import SwiftUI
import MapKit

struct NearbyStoresView: View {
    @StateObject private var locationManager = LocationManager.shared
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var showMap = false
    
    var unpurchasedItems: [ShoppingItem] {
        cloudKitManager.shoppingItems.filter { !$0.isPurchased }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if locationManager.authorizationStatus == .notDetermined {
                    permissionRequest
                } else if locationManager.authorizationStatus == .denied {
                    permissionDenied
                } else if locationManager.nearbyStores.isEmpty {
                    loadingOrEmpty
                } else {
                    storesList
                }
            }
            .navigationTitle("In der Nähe")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showMap.toggle() }) {
                        Image(systemName: showMap ? "list.bullet" : "map")
                    }
                }
            }
            .sheet(isPresented: $showMap) {
                StoresMapView(stores: locationManager.nearbyStores)
            }
        }
    }
    
    private var permissionRequest: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Standort aktivieren")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Erhalte Erinnerungen, wenn du in der Nähe von Geschäften bist")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                locationManager.requestAuthorization()
            }) {
                Text("Standort erlauben")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var permissionDenied: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Standort deaktiviert")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Bitte aktiviere den Standort in den Einstellungen")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Einstellungen öffnen")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var loadingOrEmpty: some View {
        VStack(spacing: 20) {
            if locationManager.currentLocation == nil {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Standort wird ermittelt...")
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.3))
                Text("Suche Geschäfte...")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            searchNearbyStores()
        }
    }
    
    private var storesList: some View {
        List {
            if unpurchasedItems.isEmpty {
                Section {
                    Text("Keine offenen Einkäufe")
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(locationManager.nearbyStores) { store in
                StoreRowView(store: store, itemCount: unpurchasedItems.count) {
                    setupReminder(for: store)
                }
            }
        }
        .refreshable {
            searchNearbyStores()
        }
    }
    
    private func searchNearbyStores() {
        Task {
            await locationManager.searchNearbyStores(shoppingItems: unpurchasedItems)
        }
    }
    
    private func setupReminder(for store: NearbyStore) {
        locationManager.createLocationReminder(for: store, items: unpurchasedItems)
        
        // Benachrichtigung
        NotificationManager.shared.scheduleLocationReminderNotification(
            storeName: store.name,
            itemCount: unpurchasedItems.count
        )
    }
}

struct StoreRowView: View {
    let store: NearbyStore
    let itemCount: Int
    let onSetReminder: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.name)
                        .font(.headline)
                    
                    Text(store.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(store.distanceFormatted)
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text(store.type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if itemCount > 0 {
                HStack {
                    Label("\(itemCount) Artikel", systemImage: "cart")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: onSetReminder) {
                        Label("Erinnerung", systemImage: "bell.badge")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct StoresMapView: View {
    let stores: [NearbyStore]
    @Environment(\.dismiss) var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515), // Deutschland Mitte
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, annotationItems: stores) { store in
                MapAnnotation(coordinate: store.coordinate) {
                    VStack {
                        Image(systemName: "cart.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                        
                        Text(store.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white)
                            .cornerRadius(6)
                            .shadow(radius: 2)
                    }
                }
            }
            .navigationTitle("Karte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let firstStore = stores.first {
                region.center = firstStore.coordinate
            }
        }
    }
}

#Preview {
    NearbyStoresView()
        .environmentObject(CloudKitManager.shared)
}
