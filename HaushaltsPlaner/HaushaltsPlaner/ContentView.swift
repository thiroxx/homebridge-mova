import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var aiManager = AIInsightsManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TasksView()
                .tabItem {
                    Label("Aufgaben", systemImage: "checkmark.circle.fill")
                }
                .tag(0)
            
            ShoppingView()
                .tabItem {
                    Label("Einkaufen", systemImage: "cart.fill")
                }
                .tag(1)
                .badge(unpurchasedCount)
            
            NearbyStoresView()
                .tabItem {
                    Label("In der Nähe", systemImage: "location.fill")
                }
                .tag(2)
            
            SmartInsightsView()
                .tabItem {
                    Label("Insights", systemImage: "sparkles")
                }
                .tag(3)
                .badge(insightsCount)
            
            FamilyView()
                .tabItem {
                    Label("Familie", systemImage: "person.3.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .alert("iCloud Fehler", isPresented: $cloudKitManager.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(cloudKitManager.errorMessage)
        }
        .onAppear {
            setupManagers()
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToTasks)) { _ in
            selectedTab = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToShopping)) { _ in
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToFamily)) { _ in
            selectedTab = 4
        }
    }
    
    private var unpurchasedCount: Int {
        cloudKitManager.shoppingItems.filter { !$0.isPurchased }.count
    }
    
    private var insightsCount: Int {
        aiManager.taskSuggestions.count + aiManager.shoppingPredictions.count
    }
    
    private func setupManagers() {
        // Location Manager Setup
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAuthorization()
        } else {
            locationManager.startTracking()
        }
        
        // AI Insights initialisieren
        Task {
            await aiManager.analyzeTaskPatterns(
                tasks: cloudKitManager.tasks,
                location: locationManager.currentLocation
            )
            aiManager.analyzeShoppingItems(cloudKitManager.shoppingItems)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CloudKitManager.shared)
}
