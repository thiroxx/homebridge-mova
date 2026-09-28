import Foundation
import Combine
import WeatherKit
import CoreLocation

class AIInsightsManager: ObservableObject {
    static let shared = AIInsightsManager()
    
    @Published var insights: [AIInsight] = []
    @Published var shoppingPredictions: [ShoppingPrediction] = []
    @Published var taskSuggestions: [TaskSuggestion] = []
    @Published var taskCompletions: [TaskCompletionRecord] = []
    
    private let userDefaults = UserDefaults.standard
    private let purchaseHistoryKey = "purchaseHistory"
    private let taskCompletionHistoryKey = "taskCompletionHistory"
    
    init() {
        loadTaskCompletions()
    }
    
    // MARK: - Shopping Predictions
    
    func analyzeShopping items: [ShoppingItem]) {
        let history = loadPurchaseHistory()
        var predictions: [ShoppingPrediction] = []
        
        // Analyse der Kaufmuster
        let itemFrequency = calculateItemFrequency(from: history)
        
        for (itemName, frequency) in itemFrequency {
            if let lastPurchase = findLastPurchase(of: itemName, in: history) {
                let daysSince = daysBetween(lastPurchase, and: Date())
                let avgInterval = frequency.averageInterval
                
                // Vorhersage basierend auf Intervall
                if daysSince >= avgInterval * 0.8 {
                    let daysUntilNeeded = Int(avgInterval - Double(daysSince))
                    let urgency: PredictionUrgency
                    
                    if daysUntilNeeded <= 0 {
                        urgency = .now
                    } else if daysUntilNeeded <= 1 {
                        urgency = .soon
                    } else {
                        urgency = .upcoming
                    }
                    
                    let prediction = ShoppingPrediction(
                        itemName: itemName,
                        averageInterval: avgInterval,
                        daysSinceLastPurchase: daysSince,
                        confidence: frequency.confidence,
                        urgency: urgency,
                        message: generateShoppingMessage(
                            item: itemName,
                            daysSince: daysSince,
                            avgInterval: avgInterval
                        )
                    )
                    
                    predictions.append(prediction)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.shoppingPredictions = predictions.sorted { $0.urgency.sortOrder < $1.urgency.sortOrder }
        }
    }
    
    private func generateShoppingMessage(item: String, daysSince: Int, avgInterval: Double) -> String {
        let interval = Int(avgInterval)
        
        if daysSince >= interval {
            return "Du kaufst normalerweise \(item) alle \(interval) Tage. Letzte Mal: vor \(daysSince) Tagen."
        } else {
            let remaining = interval - daysSince
            return "Du kaufst \(item) normalerweise alle \(interval) Tage. Bald wieder nötig (in ca. \(remaining) Tagen)."
        }
    }
    
    // MARK: - Task Suggestions
    
    func analyzeTaskPatterns(tasks: [HouseholdTask], location: CLLocation?) async {
        var suggestions: [TaskSuggestion] = []
        
        // 1. Wetterbasierte Vorschläge
        if let location = location {
            let weatherSuggestions = await generateWeatherBasedSuggestions(location: location, tasks: tasks)
            suggestions.append(contentsOf: weatherSuggestions)
        }
        
        // 2. Zeitbasierte Muster
        let timeSuggestions = analyzeTimePatterns(tasks: tasks)
        suggestions.append(contentsOf: timeSuggestions)
        
        // 3. Saisonale Vorschläge
        let seasonalSuggestions = generateSeasonalSuggestions()
        suggestions.append(contentsOf: seasonalSuggestions)
        
        // 4. Überfällige Aufgaben
        let overdueSuggestions = findOverdueTasks(tasks: tasks)
        suggestions.append(contentsOf: overdueSuggestions)
        
        await MainActor.run {
            self.taskSuggestions = suggestions.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        }
    }
    
    // MARK: - Weather-Based Suggestions
    
    private func generateWeatherBasedSuggestions(location: CLLocation, tasks: [HouseholdTask]) async -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        
        // Simuliere Wetterdaten (in Produktion: WeatherKit verwenden)
        let weather = simulateWeather()
        
        // Fenster putzen bei gutem Wetter
        if weather.condition == .sunny && weather.temperature > 15 {
            if !hasRecentTask(titled: "Fenster putzen", in: tasks, days: 14) {
                suggestions.append(TaskSuggestion(
                    title: "Fenster putzen",
                    reason: "Perfektes Wetter heute: ☀️ \(Int(weather.temperature))°C",
                    priority: .medium,
                    suggestedDate: Date(),
                    type: .weatherBased
                ))
            }
        }
        
        // Garten gießen bei Trockenheit
        if weather.condition == .sunny && weather.temperature > 20 {
            if !hasRecentTask(titled: "Garten gießen", in: tasks, days: 2) {
                suggestions.append(TaskSuggestion(
                    title: "Garten gießen",
                    reason: "Trocken und warm - Pflanzen brauchen Wasser",
                    priority: .high,
                    suggestedDate: Date(),
                    type: .weatherBased
                ))
            }
        }
        
        // Wäsche draußen trocknen
        if weather.condition == .sunny {
            suggestions.append(TaskSuggestion(
                title: "Wäsche draußen trocknen",
                reason: "Sonnig - perfekt zum Trocknen",
                priority: .low,
                suggestedDate: Date(),
                type: .weatherBased
            ))
        }
        
        // Regenwetter-Aufgaben
        if weather.condition == .rainy {
            if !hasRecentTask(titled: "Keller aufräumen", in: tasks, days: 30) {
                suggestions.append(TaskSuggestion(
                    title: "Keller aufräumen",
                    reason: "Regenwetter - gute Zeit für Indoor-Aufgaben",
                    priority: .low,
                    suggestedDate: Date(),
                    type: .weatherBased
                ))
            }
        }
        
        return suggestions
    }
    
    private func simulateWeather() -> (condition: WeatherCondition, temperature: Double) {
        // In Produktion: Echte WeatherKit Integration
        let conditions: [WeatherCondition] = [.sunny, .cloudy, .rainy]
        let condition = conditions.randomElement() ?? .sunny
        let temp = Double.random(in: 10...25)
        return (condition, temp)
    }
    
    enum WeatherCondition {
        case sunny, cloudy, rainy
    }
    
    // MARK: - Time Pattern Analysis
    
    private func analyzeTimePatterns(tasks: [HouseholdTask]) -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        let history = loadTaskCompletionHistory()
        
        // Finde wiederkehrende Muster
        let patterns = findRecurringPatterns(in: history)
        
        for pattern in patterns {
            let daysSinceLast = daysBetween(pattern.lastCompletion, and: Date())
            
            if daysSinceLast >= pattern.averageInterval * 0.9 {
                suggestions.append(TaskSuggestion(
                    title: pattern.taskTitle,
                    reason: "Normalerweise alle \(Int(pattern.averageInterval)) Tage - letztes Mal vor \(daysSinceLast) Tagen",
                    priority: daysSinceLast > pattern.averageInterval ? .high : .medium,
                    suggestedDate: Date(),
                    type: .patternBased
                ))
            }
        }
        
        return suggestions
    }
    
    // MARK: - Seasonal Suggestions
    
    private func generateSeasonalSuggestions() -> [TaskSuggestion] {
        var suggestions: [TaskSuggestion] = []
        let month = Calendar.current.component(.month, from: Date())
        
        switch month {
        case 3, 4: // Frühling
            suggestions.append(TaskSuggestion(
                title: "Frühjahrsputz",
                reason: "Frühlingszeit - perfekt für Großputz",
                priority: .medium,
                suggestedDate: Date(),
                type: .seasonal
            ))
            suggestions.append(TaskSuggestion(
                title: "Balkon/Terrasse vorbereiten",
                reason: "Bald ist Balkon-Saison!",
                priority: .low,
                suggestedDate: Date(),
                type: .seasonal
            ))
            
        case 9, 10: // Herbst
            suggestions.append(TaskSuggestion(
                title: "Heizung warten",
                reason: "Vor der Heizperiode prüfen",
                priority: .high,
                suggestedDate: Date(),
                type: .seasonal
            ))
            suggestions.append(TaskSuggestion(
                title: "Winterreifen aufziehen",
                reason: "Bald wird's kalt",
                priority: .medium,
                suggestedDate: Date(),
                type: .seasonal
            ))
            
        case 11, 12: // Winter
            suggestions.append(TaskSuggestion(
                title: "Lichterkette testen",
                reason: "Weihnachtszeit steht vor der Tür",
                priority: .low,
                suggestedDate: Date(),
                type: .seasonal
            ))
            
        case 6, 7, 8: // Sommer
            suggestions.append(TaskSuggestion(
                title: "Grill reinigen",
                reason: "Grillsaison!",
                priority: .low,
                suggestedDate: Date(),
                type: .seasonal
            ))
            
        default:
            break
        }
        
        return suggestions
    }
    
    // MARK: - Overdue Tasks
    
    private func findOverdueTasks(tasks: [HouseholdTask]) -> [TaskSuggestion] {
        let overdueTasks = tasks.filter { task in
            guard let dueDate = task.dueDate, !task.isCompleted else { return false }
            return dueDate < Date()
        }
        
        return overdueTasks.map { task in
            let daysOverdue = daysBetween(task.dueDate!, and: Date())
            
            TaskSuggestion(
                title: task.title,
                reason: "Überfällig seit \(daysOverdue) Tag(en)",
                priority: .urgent,
                suggestedDate: Date(),
                type: .overdue
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func hasRecentTask(titled: String, in tasks: [HouseholdTask], days: Int) -> Bool {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        
        return tasks.contains { task in
            task.title.lowercased().contains(titled.lowercased()) &&
            task.completedAt ?? task.createdAt > cutoffDate
        }
    }
    
    private func calculateItemFrequency(from history: [PurchaseRecord]) -> [String: ItemFrequency] {
        var frequency: [String: [Date]] = [:]
        
        for record in history {
            if frequency[record.itemName] == nil {
                frequency[record.itemName] = []
            }
            frequency[record.itemName]?.append(record.date)
        }
        
        var result: [String: ItemFrequency] = [:]
        
        for (item, dates) in frequency where dates.count > 1 {
            let sorted = dates.sorted()
            var intervals: [Double] = []
            
            for i in 1..<sorted.count {
                let days = daysBetween(sorted[i-1], and: sorted[i])
                intervals.append(Double(days))
            }
            
            let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
            let confidence = min(Double(dates.count) / 10.0, 1.0) // Max confidence bei 10+ Käufen
            
            result[item] = ItemFrequency(
                count: dates.count,
                averageInterval: avgInterval,
                confidence: confidence
            )
        }
        
        return result
    }
    
    private func findRecurringPatterns(in history: [TaskCompletionRecord]) -> [TaskPattern] {
        var patterns: [String: [Date]] = [:]
        
        for record in history {
            if patterns[record.taskTitle] == nil {
                patterns[record.taskTitle] = []
            }
            patterns[record.taskTitle]?.append(record.completionDate)
        }
        
        return patterns.compactMap { title, dates -> TaskPattern? in
            guard dates.count >= 2 else { return nil }
            
            let sorted = dates.sorted()
            var intervals: [Double] = []
            
            for i in 1..<sorted.count {
                let days = daysBetween(sorted[i-1], and: sorted[i])
                intervals.append(Double(days))
            }
            
            let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
            
            return TaskPattern(
                taskTitle: title,
                averageInterval: avgInterval,
                lastCompletion: sorted.last!,
                completionCount: dates.count
            )
        }
    }
    
    private func findLastPurchase(of item: String, in history: [PurchaseRecord]) -> Date? {
        history
            .filter { $0.itemName == item }
            .map { $0.date }
            .max()
    }
    
    private func daysBetween(_ date1: Date, and date2: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return abs(components.day ?? 0)
    }
    
    // MARK: - Persistence
    
    func recordPurchase(item: ShoppingItem) {
        var history = loadPurchaseHistory()
        history.append(PurchaseRecord(
            itemName: item.name,
            date: Date(),
            category: item.category.rawValue
        ))
        
        // Behalte nur letzten 500 Einträge
        if history.count > 500 {
            history = Array(history.suffix(500))
        }
        
        savePurchaseHistory(history)
    }
    
    func recordTaskCompletion(task: HouseholdTask) {
        var history = loadTaskCompletionHistory()
        history.append(TaskCompletionRecord(
            taskTitle: task.title,
            completionDate: Date(),
            assignedTo: task.assignedToName ?? "Unbekannt"
        ))
        
        if history.count > 500 {
            history = Array(history.suffix(500))
        }
        
        saveTaskCompletionHistory(history)
        taskCompletions = history
    }
    
    private func loadPurchaseHistory() -> [PurchaseRecord] {
        guard let data = userDefaults.data(forKey: purchaseHistoryKey),
              let history = try? JSONDecoder().decode([PurchaseRecord].self, from: data) else {
            return []
        }
        return history
    }
    
    private func savePurchaseHistory(_ history: [PurchaseRecord]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: purchaseHistoryKey)
        }
    }
    
    private func loadTaskCompletionHistory() -> [TaskCompletionRecord] {
        guard let data = userDefaults.data(forKey: taskCompletionHistoryKey),
              let history = try? JSONDecoder().decode([TaskCompletionRecord].self, from: data) else {
            return []
        }
        return history
    }
    
    private func saveTaskCompletionHistory(_ history: [TaskCompletionRecord]) {
        if let data = try? JSONEncoder().encode(history) {
            userDefaults.set(data, forKey: taskCompletionHistoryKey)
        }
    }
    
    private func loadTaskCompletions() {
        taskCompletions = loadTaskCompletionHistory()
    }
}

// MARK: - Models

struct AIInsight: Identifiable {
    let id = UUID()
    let type: InsightType
    let title: String
    let message: String
    let priority: InsightPriority
    let actionable: Bool
    let suggestedAction: String?
    
    enum InsightType {
        case shopping, task, pattern, weather, seasonal
    }
    
    enum InsightPriority {
        case low, medium, high, urgent
        
        var sortOrder: Int {
            switch self {
            case .urgent: return 0
            case .high: return 1
            case .medium: return 2
            case .low: return 3
            }
        }
    }
}

struct ShoppingPrediction: Identifiable {
    let id = UUID()
    let itemName: String
    let averageInterval: Double
    let daysSinceLastPurchase: Int
    let confidence: Double
    let urgency: PredictionUrgency
    let message: String
}

enum PredictionUrgency {
    case now, soon, upcoming
    
    var sortOrder: Int {
        switch self {
        case .now: return 0
        case .soon: return 1
        case .upcoming: return 2
        }
    }
    
    var color: String {
        switch self {
        case .now: return "red"
        case .soon: return "orange"
        case .upcoming: return "blue"
        }
    }
}

struct TaskSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let reason: String
    let priority: SuggestionPriority
    let suggestedDate: Date
    let type: SuggestionType
    
    enum SuggestionPriority {
        case low, medium, high, urgent
        
        var sortOrder: Int {
            switch self {
            case .urgent: return 0
            case .high: return 1
            case .medium: return 2
            case .low: return 3
            }
        }
    }
    
    enum SuggestionType {
        case weatherBased, patternBased, seasonal, overdue
    }
}

struct ItemFrequency {
    let count: Int
    let averageInterval: Double
    let confidence: Double
}

struct TaskPattern {
    let taskTitle: String
    let averageInterval: Double
    let lastCompletion: Date
    let completionCount: Int
}

struct PurchaseRecord: Codable {
    let itemName: String
    let date: Date
    let category: String
}

struct TaskCompletionRecord: Codable {
    let taskTitle: String
    let completionDate: Date
    let assignedTo: String
}
