import SwiftUI

struct ShoppingItemRowView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    let item: ShoppingItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: togglePurchased) {
                Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(item.isPurchased ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(item.isPurchased ? .secondary : .primary)
                    .strikethrough(item.isPurchased)
                
                HStack(spacing: 8) {
                    Text(item.quantity)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let addedByName = item.addedByName {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(addedByName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private func togglePurchased() {
        var updatedItem = item
        updatedItem.isPurchased.toggle()
        updatedItem.purchasedAt = updatedItem.isPurchased ? Date() : nil
        
        Task {
            await cloudKitManager.updateShoppingItem(updatedItem)
        }
    }
}

#Preview {
    ShoppingItemRowView(item: ShoppingItem(
        name: "Milch",
        quantity: "2L",
        category: .groceries,
        addedBy: "user123",
        addedByName: "Max"
    ))
    .environmentObject(CloudKitManager.shared)
}
