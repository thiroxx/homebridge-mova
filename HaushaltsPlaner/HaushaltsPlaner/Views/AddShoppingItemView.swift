import SwiftUI

struct AddShoppingItemView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @StateObject private var autoCompletion = AutoCompletionManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var quantity = "1"
    @State private var category: ShoppingCategory = .groceries
    @State private var priority: ShoppingPriority = .low
    @State private var showingSuggestions = false
    
    var filteredSuggestions: [String] {
        autoCompletion.getShoppingItemSuggestions(for: name)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Artikeldetails") {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Name", text: $name)
                            .font(.headline)
                            .onChange(of: name) { _, newValue in
                                showingSuggestions = !newValue.isEmpty
                            }
                        
                        if showingSuggestions && !filteredSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                    .padding(.vertical, 8)
                                
                                ForEach(filteredSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        name = suggestion
                                        showingSuggestions = false
                                    }) {
                                        HStack {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .foregroundColor(.secondary)
                                                .font(.caption)
                                            Text(suggestion)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.vertical, 6)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    if suggestion != filteredSuggestions.last {
                                        Divider()
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    
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
                
                Section("Priorität") {
                    Picker("Priorität", selection: $priority) {
                        ForEach(ShoppingPriority.allCases, id: \.self) { priority in
                            HStack {
                                Text(priority.rawValue)
                                Spacer()
                                Circle()
                                    .fill(priorityColor(priority))
                                    .frame(width: 12, height: 12)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if !autoCompletion.shoppingItemSuggestions.isEmpty {
                    Section("Häufig gekauft") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(autoCompletion.getSmartShoppingItemSuggestions(for: category).prefix(6)), id: \.self) { suggestion in
                                    Button(action: {
                                        name = suggestion
                                        showingSuggestions = false
                                    }) {
                                        Text(suggestion)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(16)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
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
        
        autoCompletion.addShoppingItemToHistory(name)
        
        let item = ShoppingItem(
            name: name,
            quantity: quantity,
            category: category,
            priority: priority,
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
    
    private func priorityColor(_ priority: ShoppingPriority) -> Color {
        switch priority.color {
        case "gray": return .gray
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    AddShoppingItemView()
        .environmentObject(CloudKitManager.shared)
}
