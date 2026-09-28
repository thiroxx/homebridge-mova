import SwiftUI

struct AddShoppingItemView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var quantity = "1"
    @State private var category: ShoppingCategory = .groceries
    
    var body: some View {
        NavigationView {
            Form {
                Section("Artikeldetails") {
                    TextField("Name", text: $name)
                        .font(.headline)
                    
                    TextField("Menge", text: $quantity)
                }
                
                Section("Kategorie") {
                    Picker("Kategorie", selection: $category) {
                        ForEach(ShoppingCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Artikel hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        addItem()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addItem() {
        guard let currentUser = cloudKitManager.currentUser else { return }
        
        let item = ShoppingItem(
            name: name,
            quantity: quantity,
            category: category,
            addedBy: currentUser.userRecordID,
            addedByName: currentUser.name
        )
        
        Task {
            await cloudKitManager.addShoppingItem(item)
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    AddShoppingItemView()
        .environmentObject(CloudKitManager.shared)
}
