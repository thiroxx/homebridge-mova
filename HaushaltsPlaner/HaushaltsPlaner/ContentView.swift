import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
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
            
            FamilyView()
                .tabItem {
                    Label("Familie", systemImage: "person.3.fill")
                }
                .tag(2)
        }
        .accentColor(.blue)
        .alert("iCloud Fehler", isPresented: $cloudKitManager.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(cloudKitManager.errorMessage)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CloudKitManager.shared)
}
