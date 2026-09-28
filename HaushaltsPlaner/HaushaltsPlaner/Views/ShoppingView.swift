import SwiftUI

struct ShoppingView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var showingAddItem = false
    @State private var selectedCategory: ShoppingCategory?
    
    var filteredItems: [ShoppingItem] {
        if let category = selectedCategory {
            return cloudKitManager.shoppingItems.filter { $0.category == category }
        }
        return cloudKitManager.shoppingItems
    }
    
    var groupedItems: [(category: ShoppingCategory, items: [ShoppingItem])] {
        let items = filteredItems
        let grouped = Dictionary(grouping: items) { $0.category }
        return ShoppingCategory.allCases.compactMap { category in
            if let items = grouped[category], !items.isEmpty {
                let sortedItems = items.sorted { item1, item2 in
                    if item1.isPurchased != item2.isPurchased {
                        return !item1.isPurchased
                    }
                    if item1.priority.sortOrder != item2.priority.sortOrder {
                        return item1.priority.sortOrder < item2.priority.sortOrder
                    }
                    return item1.addedAt > item2.addedAt
                }
                return (category, sortedItems)
            }
            return nil
        }
    }
    
    var unpurchasedCount: Int {
        cloudKitManager.shoppingItems.filter { !$0.isPurchased }.count
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                categoryFilter
                
                if filteredItems.isEmpty {
                    emptyState
                } else {
                    shoppingList
                }
            }
            .navigationTitle("Einkaufsliste")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                
                if unpurchasedCount > 0 {
                    ToolbarItem(placement: .status) {
                        Text("\(unpurchasedCount) offen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddShoppingItemView()
            }
            .refreshable {
                await cloudKitManager.fetchShoppingItems()
            }
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "Alle",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(ShoppingCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: "\(category.icon) \(category.rawValue)",
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private var shoppingList: some View {
        List {
            ForEach(groupedItems, id: \.category) { group in
                Section(header: Text("\(group.category.icon) \(group.category.rawValue)")) {
                    ForEach(group.items) { item in
                        ShoppingItemRowView(item: item)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await cloudKitManager.deleteShoppingItem(item)
                                    }
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Einkaufsliste ist leer")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Füge Artikel hinzu")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddItem = true }) {
                Label("Artikel hinzufügen", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ShoppingView()
        .environmentObject(CloudKitManager.shared)
}
