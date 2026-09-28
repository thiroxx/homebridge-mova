import SwiftUI
import CloudKit

struct FamilyView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var showingShareSheet = false
    @State private var shareURL: URL?
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(cloudKitManager.familyMembers) { member in
                        FamilyMemberRow(member: member)
                    }
                } header: {
                    Text("Familienmitglieder")
                } footer: {
                    Text("Teile die App mit deiner Familie über iCloud Family Sharing.")
                }
                
                Section {
                    Button(action: shareWithFamily) {
                        Label("Familie einladen", systemImage: "person.badge.plus")
                            .foregroundColor(.blue)
                    }
                } footer: {
                    Text("Sende eine Einladung über iCloud, um die Haushaltsplaner-Daten mit deiner Familie zu teilen.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(
                            icon: "checkmark.circle.fill",
                            title: "Aufgaben gemeinsam verwalten",
                            description: "Erstelle und weise Aufgaben allen Familienmitgliedern zu"
                        )
                        
                        Divider()
                        
                        FeatureRow(
                            icon: "cart.fill",
                            title: "Einkaufsliste synchronisieren",
                            description: "Alle sehen die gleiche Einkaufsliste in Echtzeit"
                        )
                        
                        Divider()
                        
                        FeatureRow(
                            icon: "icloud.fill",
                            title: "iCloud Synchronisation",
                            description: "Automatische Synchronisation über alle Geräte"
                        )
                        
                        Divider()
                        
                        FeatureRow(
                            icon: "mic.fill",
                            title: "Siri & HomePod",
                            description: "Füge Aufgaben per Sprachbefehl hinzu"
                        )
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Funktionen")
                }
            }
            .navigationTitle("Familie")
            .sheet(isPresented: $showingShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func shareWithFamily() {
        Task {
            do {
                let share = try await cloudKitManager.shareWithFamily()
                if let url = share.url {
                    await MainActor.run {
                        self.shareURL = url
                        self.showingShareSheet = true
                    }
                }
            } catch {
                print("Fehler beim Teilen: \(error)")
            }
        }
    }
}

struct FamilyMemberRow: View {
    let member: FamilyMember
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(memberColor)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(member.name.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                    
                    if member.isOwner {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                if let email = member.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var memberColor: Color {
        switch member.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "pink": return .pink
        case "red": return .red
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .blue
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    FamilyView()
        .environmentObject(CloudKitManager.shared)
}
