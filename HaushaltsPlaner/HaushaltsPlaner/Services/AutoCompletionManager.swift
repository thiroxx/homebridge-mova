import Foundation
import Combine

class AutoCompletionManager: ObservableObject {
    static let shared = AutoCompletionManager()
    
    @Published var taskSuggestions: [String] = []
    @Published var shoppingItemSuggestions: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let taskHistoryKey = "taskHistory"
    private let shoppingHistoryKey = "shoppingHistory"
    private let maxHistoryItems = 50
    
    init() {
        loadHistory()
    }
    
    private func loadHistory() {
        if let taskHistory = userDefaults.stringArray(forKey: taskHistoryKey) {
            taskSuggestions = Array(taskHistory.prefix(maxHistoryItems))
        }
        if let shoppingHistory = userDefaults.stringArray(forKey: shoppingHistoryKey) {
            shoppingItemSuggestions = Array(shoppingHistory.prefix(maxHistoryItems))
        }
    }
    
    func addTaskToHistory(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var history = userDefaults.stringArray(forKey: taskHistoryKey) ?? []
        
        if let existingIndex = history.firstIndex(of: trimmed) {
            history.remove(at: existingIndex)
        }
        
        history.insert(trimmed, at: 0)
        
        history = Array(history.prefix(maxHistoryItems))
        
        userDefaults.set(history, forKey: taskHistoryKey)
        taskSuggestions = history
    }
    
    func addShoppingItemToHistory(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var history = userDefaults.stringArray(forKey: shoppingHistoryKey) ?? []
        
        if let existingIndex = history.firstIndex(of: trimmed) {
            history.remove(at: existingIndex)
        }
        
        history.insert(trimmed, at: 0)
        
        history = Array(history.prefix(maxHistoryItems))
        
        userDefaults.set(history, forKey: shoppingHistoryKey)
        shoppingItemSuggestions = history
    }
    
    func getTaskSuggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return Array(taskSuggestions.prefix(5)) }
        
        let lowercasedQuery = query.lowercased()
        return taskSuggestions.filter { suggestion in
            suggestion.lowercased().contains(lowercasedQuery)
        }.prefix(5).map { $0 }
    }
    
    func getShoppingItemSuggestions(for query: String) -> [String] {
        guard !query.isEmpty else { return Array(shoppingItemSuggestions.prefix(5)) }
        
        let lowercasedQuery = query.lowercased()
        return shoppingItemSuggestions.filter { suggestion in
            suggestion.lowercased().contains(lowercasedQuery)
        }.prefix(5).map { $0 }
    }
    
    func getSmartShoppingItemSuggestions(for category: ShoppingCategory) -> [String] {
        let commonItems: [ShoppingCategory: [String]] = [
            .groceries: [
                "Milch", "Brot", "Butter", "Eier", "Käse",
                "Joghurt", "Äpfel", "Bananen", "Tomaten", "Gurken",
                "Kartoffeln", "Reis", "Nudeln", "Mehl", "Zucker",
                "Salz", "Pfeffer", "Öl", "Kaffee", "Tee"
            ],
            .household: [
                "Toilettenpapier", "Küchenpapier", "Müllbeutel", "Spülmittel",
                "Waschmittel", "Weichspüler", "Allzweckreiniger", "Schwämme",
                "Glühbirnen", "Batterien", "Alufolie", "Frischhaltefolie"
            ],
            .personal: [
                "Zahnpasta", "Zahnbürste", "Shampoo", "Duschgel", "Seife",
                "Deo", "Rasierer", "Rasierschaum", "Creme", "Taschentücher"
            ],
            .other: [
                "Blumen", "Kerzen", "Geschenkpapier", "Tierfutter"
            ]
        ]
        
        let categoryItems = commonItems[category] ?? []
        let historyItems = shoppingItemSuggestions.prefix(10)
        
        var combined = Array(historyItems)
        for item in categoryItems {
            if !combined.contains(item) {
                combined.append(item)
            }
        }
        
        return Array(combined.prefix(10))
    }
    
    func getSmartTaskSuggestions() -> [String] {
        let commonTasks = [
            "Müll rausbringen",
            "Wäsche waschen",
            "Staubsaugen",
            "Fenster putzen",
            "Bad putzen",
            "Küche aufräumen",
            "Spülmaschine ausräumen",
            "Betten beziehen",
            "Pflanzen gießen",
            "Post abholen",
            "Auto waschen",
            "Einkaufen gehen",
            "Essen vorbereiten",
            "Garage aufräumen"
        ]
        
        let historyItems = taskSuggestions.prefix(10)
        var combined = Array(historyItems)
        
        for task in commonTasks {
            if !combined.contains(task) {
                combined.append(task)
            }
        }
        
        return Array(combined.prefix(10))
    }
    
    func clearHistory() {
        userDefaults.removeObject(forKey: taskHistoryKey)
        userDefaults.removeObject(forKey: shoppingHistoryKey)
        taskSuggestions = []
        shoppingItemSuggestions = []
    }
}
