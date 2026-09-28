import Foundation
import Combine

class RecurringTasksManager: ObservableObject {
    static let shared = RecurringTasksManager()
    
    @Published var recurringTasks: [RecurringTask] = []
    @Published var aiSuggestedIntervals: [TaskIntervalSuggestion] = []
    
    private let userDefaults = UserDefaults.standard
    private let recurringTasksKey = "recurringTasks"
    
    // Vordefinierte Haushaltsaufgaben mit Best-Practice Intervallen
    let commonHouseholdTasks: [TaskIntervalTemplate] = [
        // Küche
        TaskIntervalTemplate(
            title: "Kühlschrank reinigen",
            category: .kitchen,
            suggestedInterval: 14,
            minInterval: 7,
            maxInterval: 30,
            reasoning: "Hygiene und Frische - alle 2 Wochen empfohlen"
        ),
        TaskIntervalTemplate(
            title: "Backofen reinigen",
            category: .kitchen,
            suggestedInterval: 30,
            minInterval: 14,
            maxInterval: 90,
            reasoning: "Bei regelmäßiger Nutzung monatlich"
        ),
        TaskIntervalTemplate(
            title: "Spülmaschine reinigen",
            category: .kitchen,
            suggestedInterval: 30,
            minInterval: 14,
            maxInterval: 60,
            reasoning: "Verhindert Kalkablagerungen"
        ),
        
        // Badezimmer
        TaskIntervalTemplate(
            title: "Bad putzen",
            category: .bathroom,
            suggestedInterval: 7,
            minInterval: 3,
            maxInterval: 14,
            reasoning: "Hygiene - wöchentlich empfohlen"
        ),
        TaskIntervalTemplate(
            title: "Duschkopf entkalken",
            category: .bathroom,
            suggestedInterval: 60,
            minInterval: 30,
            maxInterval: 180,
            reasoning: "Je nach Wasserhärte alle 2 Monate"
        ),
        TaskIntervalTemplate(
            title: "Waschmaschine reinigen",
            category: .bathroom,
            suggestedInterval: 30,
            minInterval: 14,
            maxInterval: 90,
            reasoning: "Verhindert Gerüche und Kalk"
        ),
        
        // Wohnraum
        TaskIntervalTemplate(
            title: "Fenster putzen",
            category: .livingArea,
            suggestedInterval: 21,
            minInterval: 14,
            maxInterval: 60,
            reasoning: "Alle 3 Wochen für klare Sicht"
        ),
        TaskIntervalTemplate(
            title: "Staubsaugen",
            category: .livingArea,
            suggestedInterval: 3,
            minInterval: 2,
            maxInterval: 7,
            reasoning: "2-3x pro Woche bei Teppich"
        ),
        TaskIntervalTemplate(
            title: "Wischen",
            category: .livingArea,
            suggestedInterval: 7,
            minInterval: 3,
            maxInterval: 14,
            reasoning: "Wöchentlich für saubere Böden"
        ),
        TaskIntervalTemplate(
            title: "Staub wischen",
            category: .livingArea,
            suggestedInterval: 7,
            minInterval: 3,
            maxInterval: 14,
            reasoning: "Wöchentlich gegen Allergene"
        ),
        
        // Schlafzimmer
        TaskIntervalTemplate(
            title: "Bettwäsche wechseln",
            category: .bedroom,
            suggestedInterval: 14,
            minInterval: 7,
            maxInterval: 21,
            reasoning: "Hygiene - alle 2 Wochen"
        ),
        TaskIntervalTemplate(
            title: "Matratze wenden",
            category: .bedroom,
            suggestedInterval: 90,
            minInterval: 60,
            maxInterval: 180,
            reasoning: "Verlängert Lebensdauer"
        ),
        
        // Außenbereich
        TaskIntervalTemplate(
            title: "Balkon/Terrasse reinigen",
            category: .outdoor,
            suggestedInterval: 30,
            minInterval: 14,
            maxInterval: 90,
            reasoning: "Monatlich oder saisonal"
        ),
        TaskIntervalTemplate(
            title: "Garten gießen",
            category: .outdoor,
            suggestedInterval: 2,
            minInterval: 1,
            maxInterval: 7,
            reasoning: "Im Sommer täglich bis alle 3 Tage"
        ),
        TaskIntervalTemplate(
            title: "Rasen mähen",
            category: .outdoor,
            suggestedInterval: 7,
            minInterval: 5,
            maxInterval: 14,
            reasoning: "Wöchentlich in Wachstumsperiode"
        ),
        
        // Wartung
        TaskIntervalTemplate(
            title: "Heizung warten",
            category: .maintenance,
            suggestedInterval: 365,
            minInterval: 180,
            maxInterval: 730,
            reasoning: "Jährlich vor Heizperiode"
        ),
        TaskIntervalTemplate(
            title: "Rauchmelder testen",
            category: .maintenance,
            suggestedInterval: 180,
            minInterval: 90,
            maxInterval: 365,
            reasoning: "Alle 6 Monate für Sicherheit"
        ),
        TaskIntervalTemplate(
            title: "Filter Dunstabzug wechseln",
            category: .maintenance,
            suggestedInterval: 90,
            minInterval: 60,
            maxInterval: 180,
            reasoning: "Alle 3 Monate bei regelmäßiger Nutzung"
        ),
        TaskIntervalTemplate(
            title: "Luftfilter wechseln",
            category: .maintenance,
            suggestedInterval: 180,
            minInterval: 90,
            maxInterval: 365,
            reasoning: "Halbjährlich für saubere Luft"
        )
    ]
    
    init() {
        loadRecurringTasks()
    }
    
    // MARK: - AI Interval Suggestions
    
    func analyzeAndSuggestIntervals(from history: [TaskCompletionRecord]) async {
        var suggestions: [TaskIntervalSuggestion] = []
        
        // 1. Analysiere Benutzer-Muster
        let userPatterns = analyzeUserPatterns(from: history)
        
        for pattern in userPatterns {
            // Vergleiche mit Best Practice
            if let template = findMatchingTemplate(for: pattern.taskTitle) {
                let suggestion = compareWithBestPractice(
                    userPattern: pattern,
                    template: template
                )
                suggestions.append(suggestion)
            } else {
                // Keine Best Practice gefunden - erstelle Vorschlag aus Muster
                let suggestion = createSuggestionFromPattern(pattern)
                suggestions.append(suggestion)
            }
        }
        
        // 2. Schlage neue Tasks vor basierend auf Templates
        let missingSuggestions = suggestMissingTasks(existingPatterns: userPatterns)
        suggestions.append(contentsOf: missingSuggestions)
        
        await MainActor.run {
            self.aiSuggestedIntervals = suggestions.sorted { 
                $0.confidence > $1.confidence 
            }
        }
    }
    
    private func analyzeUserPatterns(from history: [TaskCompletionRecord]) -> [UserTaskPattern] {
        var patterns: [String: [Date]] = [:]
        
        for record in history {
            let normalizedTitle = normalizeTaskTitle(record.taskTitle)
            if patterns[normalizedTitle] == nil {
                patterns[normalizedTitle] = []
            }
            patterns[normalizedTitle]?.append(record.completionDate)
        }
        
        return patterns.compactMap { title, dates -> UserTaskPattern? in
            guard dates.count >= 2 else { return nil }
            
            let sorted = dates.sorted()
            var intervals: [Int] = []
            
            for i in 1..<sorted.count {
                let days = Calendar.current.dateComponents([.day], 
                    from: sorted[i-1], 
                    to: sorted[i]).day ?? 0
                intervals.append(days)
            }
            
            let avgInterval = Double(intervals.reduce(0, +)) / Double(intervals.count)
            let stdDev = calculateStandardDeviation(intervals)
            
            // Konsistenz: Je niedriger die Standardabweichung, desto konsistenter
            let consistency = 1.0 - min(stdDev / avgInterval, 1.0)
            
            return UserTaskPattern(
                taskTitle: title,
                completionCount: dates.count,
                averageInterval: avgInterval,
                standardDeviation: stdDev,
                consistency: consistency,
                lastCompletion: sorted.last!
            )
        }
    }
    
    private func compareWithBestPractice(
        userPattern: UserTaskPattern,
        template: TaskIntervalTemplate
    ) -> TaskIntervalSuggestion {
        let userInterval = Int(userPattern.averageInterval)
        let recommendedInterval = template.suggestedInterval
        
        let difference = abs(userInterval - recommendedInterval)
        let percentDiff = Double(difference) / Double(recommendedInterval)
        
        var aiReasoning = ""
        var suggestedInterval = userInterval
        var adjustmentType: IntervalAdjustment = .perfect
        
        if percentDiff < 0.1 {
            // Perfekt!
            aiReasoning = "✓ Dein Intervall ist optimal! \(userInterval) Tage entspricht Best Practice."
            adjustmentType = .perfect
        } else if userInterval < template.minInterval {
            // Zu oft
            aiReasoning = "Du machst es alle \(userInterval) Tage - das ist öfter als nötig. Empfohlen: \(recommendedInterval) Tage."
            suggestedInterval = recommendedInterval
            adjustmentType = .tooFrequent
        } else if userInterval > template.maxInterval {
            // Zu selten
            aiReasoning = "Du machst es alle \(userInterval) Tage - das könnte zu selten sein. Empfohlen: \(recommendedInterval) Tage."
            suggestedInterval = recommendedInterval
            adjustmentType = .tooRare
        } else if percentDiff < 0.3 {
            // Nah dran
            aiReasoning = "Dein Intervall (\(userInterval) Tage) ist gut! Optimal wären \(recommendedInterval) Tage."
            suggestedInterval = recommendedInterval
            adjustmentType = .nearOptimal
        } else {
            // Moderate Anpassung
            aiReasoning = "Du machst es alle \(userInterval) Tage. Empfohlen: \(recommendedInterval) Tage. \(template.reasoning)"
            suggestedInterval = recommendedInterval
            adjustmentType = .needsAdjustment
        }
        
        let confidence = min(userPattern.consistency, 1.0)
        
        return TaskIntervalSuggestion(
            taskTitle: userPattern.taskTitle,
            currentInterval: userInterval,
            suggestedInterval: suggestedInterval,
            category: template.category,
            reasoning: aiReasoning,
            basedOnData: true,
            dataPoints: userPattern.completionCount,
            confidence: confidence,
            adjustment: adjustmentType,
            template: template
        )
    }
    
    private func createSuggestionFromPattern(_ pattern: UserTaskPattern) -> TaskIntervalSuggestion {
        let interval = Int(pattern.averageInterval)
        
        let reasoning: String
        if pattern.consistency > 0.8 {
            reasoning = "Du machst '\(pattern.taskTitle)' sehr regelmäßig alle \(interval) Tage. Automatisch erstellen?"
        } else if pattern.consistency > 0.5 {
            reasoning = "Du machst '\(pattern.taskTitle)' etwa alle \(interval) Tage. Erinnerung aktivieren?"
        } else {
            reasoning = "Du machst '\(pattern.taskTitle)' unregelmäßig (Ø \(interval) Tage). Festes Intervall könnte helfen!"
        }
        
        return TaskIntervalSuggestion(
            taskTitle: pattern.taskTitle,
            currentInterval: interval,
            suggestedInterval: interval,
            category: .other,
            reasoning: reasoning,
            basedOnData: true,
            dataPoints: pattern.completionCount,
            confidence: pattern.consistency,
            adjustment: pattern.consistency > 0.7 ? .perfect : .needsAdjustment,
            template: nil
        )
    }
    
    private func suggestMissingTasks(existingPatterns: [UserTaskPattern]) -> [TaskIntervalSuggestion] {
        let existingTitles = Set(existingPatterns.map { normalizeTaskTitle($0.taskTitle) })
        
        return commonHouseholdTasks
            .filter { !existingTitles.contains(normalizeTaskTitle($0.title)) }
            .prefix(5) // Top 5 wichtigste Tasks
            .map { template in
                TaskIntervalSuggestion(
                    taskTitle: template.title,
                    currentInterval: nil,
                    suggestedInterval: template.suggestedInterval,
                    category: template.category,
                    reasoning: "Noch nie gemacht. \(template.reasoning)",
                    basedOnData: false,
                    dataPoints: 0,
                    confidence: 0.6,
                    adjustment: .newSuggestion,
                    template: template
                )
            }
    }
    
    private func findMatchingTemplate(for taskTitle: String) -> TaskIntervalTemplate? {
        let normalized = normalizeTaskTitle(taskTitle)
        return commonHouseholdTasks.first { 
            normalizeTaskTitle($0.title) == normalized ||
            normalized.contains(normalizeTaskTitle($0.title)) ||
            normalizeTaskTitle($0.title).contains(normalized)
        }
    }
    
    private func normalizeTaskTitle(_ title: String) -> String {
        title.lowercased()
            .replacingOccurrences(of: "ä", with: "a")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ß", with: "ss")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func calculateStandardDeviation(_ values: [Int]) -> Double {
        guard !values.isEmpty else { return 0 }
        let avg = Double(values.reduce(0, +)) / Double(values.count)
        let squaredDiffs = values.map { pow(Double($0) - avg, 2) }
        let variance = squaredDiffs.reduce(0, +) / Double(values.count)
        return sqrt(variance)
    }
    
    // MARK: - Recurring Tasks Management
    
    func createRecurringTask(from suggestion: TaskIntervalSuggestion, 
                           priority: TaskPriority = .medium,
                           assignTo: FamilyMember? = nil) {
        let task = RecurringTask(
            title: suggestion.taskTitle,
            intervalDays: suggestion.suggestedInterval,
            category: suggestion.category,
            priority: priority,
            assignedTo: assignTo?.userRecordID,
            assignedToName: assignTo?.name,
            isActive: true,
            nextDueDate: calculateNextDueDate(intervalDays: suggestion.suggestedInterval)
        )
        
        recurringTasks.append(task)
        saveRecurringTasks()
        
        // Erstelle erste Aufgabe
        scheduleNextOccurrence(for: task)
    }
    
    func updateRecurringTask(_ task: RecurringTask) {
        if let index = recurringTasks.firstIndex(where: { $0.id == task.id }) {
            recurringTasks[index] = task
            saveRecurringTasks()
        }
    }
    
    func deleteRecurringTask(_ task: RecurringTask) {
        recurringTasks.removeAll { $0.id == task.id }
        saveRecurringTasks()
    }
    
    func scheduleNextOccurrence(for recurringTask: RecurringTask) {
        guard recurringTask.isActive else { return }
        
        // Diese Methode wird vom CloudKitManager aufgerufen wenn eine Aufgabe erledigt wird
        let nextDate = calculateNextDueDate(
            intervalDays: recurringTask.intervalDays,
            from: Date()
        )
        
        var updated = recurringTask
        updated.nextDueDate = nextDate
        updated.lastCompletedDate = Date()
        updateRecurringTask(updated)
    }
    
    private func calculateNextDueDate(intervalDays: Int, from date: Date = Date()) -> Date {
        Calendar.current.date(byAdding: .day, value: intervalDays, to: date) ?? date
    }
    
    func checkAndCreateDueTasks(cloudKitManager: CloudKitManager) async {
        let dueTasks = recurringTasks.filter { task in
            guard task.isActive else { return false }
            return task.nextDueDate <= Date()
        }
        
        for recurringTask in dueTasks {
            guard let currentUser = cloudKitManager.currentUser else { continue }
            
            let task = HouseholdTask(
                title: recurringTask.title,
                description: "Wiederkehrende Aufgabe (alle \(recurringTask.intervalDays) Tage)",
                priority: recurringTask.priority,
                assignedTo: recurringTask.assignedTo,
                assignedToName: recurringTask.assignedToName,
                createdBy: currentUser.userRecordID,
                createdByName: currentUser.name,
                dueDate: recurringTask.nextDueDate
            )
            
            await cloudKitManager.addTask(task)
            scheduleNextOccurrence(for: recurringTask)
        }
    }
    
    // MARK: - Persistence
    
    private func loadRecurringTasks() {
        guard let data = userDefaults.data(forKey: recurringTasksKey),
              let tasks = try? JSONDecoder().decode([RecurringTask].self, from: data) else {
            return
        }
        recurringTasks = tasks
    }
    
    private func saveRecurringTasks() {
        if let data = try? JSONEncoder().encode(recurringTasks) {
            userDefaults.set(data, forKey: recurringTasksKey)
        }
    }
}

// MARK: - Models

struct RecurringTask: Identifiable, Codable {
    let id: String
    var title: String
    var intervalDays: Int
    var category: TaskCategory
    var priority: TaskPriority
    var assignedTo: String?
    var assignedToName: String?
    var isActive: Bool
    var nextDueDate: Date
    var lastCompletedDate: Date?
    var createdAt: Date
    
    init(id: String = UUID().uuidString,
         title: String,
         intervalDays: Int,
         category: TaskCategory,
         priority: TaskPriority = .medium,
         assignedTo: String? = nil,
         assignedToName: String? = nil,
         isActive: Bool = true,
         nextDueDate: Date,
         lastCompletedDate: Date? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.intervalDays = intervalDays
        self.category = category
        self.priority = priority
        self.assignedTo = assignedTo
        self.assignedToName = assignedToName
        self.isActive = isActive
        self.nextDueDate = nextDueDate
        self.lastCompletedDate = lastCompletedDate
        self.createdAt = createdAt
    }
    
    var intervalDescription: String {
        if intervalDays == 1 {
            return "Täglich"
        } else if intervalDays == 7 {
            return "Wöchentlich"
        } else if intervalDays == 14 {
            return "Alle 2 Wochen"
        } else if intervalDays == 30 {
            return "Monatlich"
        } else if intervalDays == 90 {
            return "Vierteljährlich"
        } else if intervalDays == 180 {
            return "Halbjährlich"
        } else if intervalDays == 365 {
            return "Jährlich"
        } else {
            return "Alle \(intervalDays) Tage"
        }
    }
}

struct TaskIntervalSuggestion: Identifiable {
    let id = UUID()
    let taskTitle: String
    let currentInterval: Int?
    let suggestedInterval: Int
    let category: TaskCategory
    let reasoning: String
    let basedOnData: Bool
    let dataPoints: Int
    let confidence: Double
    let adjustment: IntervalAdjustment
    let template: TaskIntervalTemplate?
}

struct TaskIntervalTemplate {
    let title: String
    let category: TaskCategory
    let suggestedInterval: Int
    let minInterval: Int
    let maxInterval: Int
    let reasoning: String
}

struct UserTaskPattern {
    let taskTitle: String
    let completionCount: Int
    let averageInterval: Double
    let standardDeviation: Double
    let consistency: Double
    let lastCompletion: Date
}

enum TaskCategory: String, Codable, CaseIterable {
    case kitchen = "Küche"
    case bathroom = "Bad"
    case livingArea = "Wohnbereich"
    case bedroom = "Schlafzimmer"
    case outdoor = "Außen"
    case maintenance = "Wartung"
    case other = "Sonstiges"
    
    var icon: String {
        switch self {
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower"
        case .livingArea: return "sofa"
        case .bedroom: return "bed.double"
        case .outdoor: return "leaf"
        case .maintenance: return "wrench.and.screwdriver"
        case .other: return "square.grid.2x2"
        }
    }
    
    var color: String {
        switch self {
        case .kitchen: return "orange"
        case .bathroom: return "blue"
        case .livingArea: return "purple"
        case .bedroom: return "indigo"
        case .outdoor: return "green"
        case .maintenance: return "red"
        case .other: return "gray"
        }
    }
}

enum IntervalAdjustment {
    case perfect
    case nearOptimal
    case tooFrequent
    case tooRare
    case needsAdjustment
    case newSuggestion
    
    var icon: String {
        switch self {
        case .perfect: return "checkmark.circle.fill"
        case .nearOptimal: return "checkmark.circle"
        case .tooFrequent: return "arrow.down.circle"
        case .tooRare: return "arrow.up.circle"
        case .needsAdjustment: return "arrow.left.arrow.right.circle"
        case .newSuggestion: return "sparkles"
        }
    }
    
    var color: String {
        switch self {
        case .perfect: return "green"
        case .nearOptimal: return "blue"
        case .tooFrequent: return "orange"
        case .tooRare: return "red"
        case .needsAdjustment: return "yellow"
        case .newSuggestion: return "purple"
        }
    }
}
