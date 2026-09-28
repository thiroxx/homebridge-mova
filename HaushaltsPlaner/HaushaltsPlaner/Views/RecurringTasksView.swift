import SwiftUI

struct RecurringTasksView: View {
    @StateObject private var recurringManager = RecurringTasksManager.shared
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var showingAddSheet = false
    @State private var showingDetailSheet: RecurringTask?
    @State private var isLoadingSuggestions = false
    
    var body: some View {
        List {
            // AI Vorschläge Section
            if !recurringManager.aiSuggestedIntervals.isEmpty {
                Section {
                    ForEach(recurringManager.aiSuggestedIntervals.prefix(10)) { suggestion in
                        AIIntervalSuggestionRow(
                            suggestion: suggestion,
                            onAccept: {
                                acceptSuggestion(suggestion)
                            }
                        )
                    }
                } header: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("KI-Vorschläge")
                    }
                } footer: {
                    Text("Basierend auf deinen Gewohnheiten und Best Practices")
                        .font(.caption)
                }
            }
            
            // Aktive wiederkehrende Aufgaben
            if !activeRecurringTasks.isEmpty {
                Section("Aktive Serien") {
                    ForEach(activeRecurringTasks) { task in
                        RecurringTaskRow(task: task)
                            .onTapGesture {
                                showingDetailSheet = task
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteTask(task)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                                
                                Button {
                                    toggleActive(task)
                                } label: {
                                    Label("Pausieren", systemImage: "pause.circle")
                                }
                                .tint(.orange)
                            }
                    }
                }
            }
            
            // Pausierte Aufgaben
            if !pausedRecurringTasks.isEmpty {
                Section("Pausiert") {
                    ForEach(pausedRecurringTasks) { task in
                        RecurringTaskRow(task: task)
                            .opacity(0.6)
                            .onTapGesture {
                                showingDetailSheet = task
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    toggleActive(task)
                                } label: {
                                    Label("Aktivieren", systemImage: "play.circle")
                                }
                                .tint(.green)
                            }
                    }
                }
            }
            
            if recurringManager.recurringTasks.isEmpty && recurringManager.aiSuggestedIntervals.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.clockwise.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("Keine wiederkehrenden Aufgaben")
                            .font(.headline)
                        
                        Text("Erstelle Serien für regelmäßige Haushaltsaufgaben")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            loadAISuggestions()
                        } label: {
                            Label("KI-Vorschläge laden", systemImage: "sparkles")
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Wiederkehrende Aufgaben")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Manuell erstellen", systemImage: "plus.circle")
                    }
                    
                    Button {
                        loadAISuggestions()
                    } label: {
                        Label("KI-Vorschläge laden", systemImage: "sparkles")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CreateRecurringTaskSheet()
        }
        .sheet(item: $showingDetailSheet) { task in
            RecurringTaskDetailSheet(task: task)
        }
        .refreshable {
            loadAISuggestions()
        }
        .onAppear {
            if recurringManager.aiSuggestedIntervals.isEmpty {
                loadAISuggestions()
            }
        }
    }
    
    private var activeRecurringTasks: [RecurringTask] {
        recurringManager.recurringTasks.filter { $0.isActive }
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }
    
    private var pausedRecurringTasks: [RecurringTask] {
        recurringManager.recurringTasks.filter { !$0.isActive }
    }
    
    private func loadAISuggestions() {
        isLoadingSuggestions = true
        Task {
            // Lade Aufgaben-Historie aus CloudKit
            let history = AIInsightsManager.shared.taskCompletions
            await recurringManager.analyzeAndSuggestIntervals(from: history)
            isLoadingSuggestions = false
        }
    }
    
    private func acceptSuggestion(_ suggestion: TaskIntervalSuggestion) {
        recurringManager.createRecurringTask(
            from: suggestion,
            priority: .medium,
            assignTo: cloudKitManager.currentUser
        )
    }
    
    private func toggleActive(_ task: RecurringTask) {
        var updated = task
        updated.isActive.toggle()
        recurringManager.updateRecurringTask(updated)
    }
    
    private func deleteTask(_ task: RecurringTask) {
        recurringManager.deleteRecurringTask(task)
    }
}

struct RecurringTaskRow: View {
    let task: RecurringTask
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.category.icon)
                .font(.title2)
                .foregroundColor(categoryColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Label(task.intervalDescription, systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let assigned = task.assignedToName {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text(assigned)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(relativeDate)
                    .font(.caption)
                    .foregroundColor(isOverdue ? .red : .secondary)
                
                if isOverdue {
                    Text("Überfällig")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .bold()
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var categoryColor: Color {
        switch task.category.color {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "indigo": return .indigo
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
    
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.localizedString(for: task.nextDueDate, relativeTo: Date())
    }
    
    private var isOverdue: Bool {
        task.nextDueDate < Date()
    }
}

struct AIIntervalSuggestionRow: View {
    let suggestion: TaskIntervalSuggestion
    let onAccept: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: suggestion.category.icon)
                    .foregroundColor(categoryColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.taskTitle)
                        .font(.headline)
                    
                    Text(suggestion.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: suggestion.adjustment.icon)
                    .foregroundColor(adjustmentColor)
                    .font(.title3)
            }
            
            Text(suggestion.reasoning)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let current = suggestion.currentInterval {
                        HStack {
                            Text("Aktuell:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("alle \(current) Tage")
                                .font(.caption)
                                .bold()
                        }
                    }
                    
                    HStack {
                        Text("Empfohlen:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("alle \(suggestion.suggestedInterval) Tage")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                if suggestion.basedOnData {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("\(Int(suggestion.confidence * 100))%")
                                .font(.caption)
                                .bold()
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption2)
                        }
                        .foregroundColor(confidenceColor)
                        
                        Text("\(suggestion.dataPoints) Einträge")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Button {
                onAccept()
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Serie erstellen")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .tint(.green)
        }
        .padding(.vertical, 8)
    }
    
    private var categoryColor: Color {
        switch suggestion.category.color {
        case "orange": return .orange
        case "blue": return .blue
        case "purple": return .purple
        case "indigo": return .indigo
        case "green": return .green
        case "red": return .red
        default: return .gray
        }
    }
    
    private var adjustmentColor: Color {
        switch suggestion.adjustment.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "red": return .red
        case "yellow": return .yellow
        case "purple": return .purple
        default: return .gray
        }
    }
    
    private var confidenceColor: Color {
        if suggestion.confidence > 0.8 {
            return .green
        } else if suggestion.confidence > 0.5 {
            return .orange
        } else {
            return .gray
        }
    }
}

struct CreateRecurringTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var recurringManager = RecurringTasksManager.shared
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    @State private var title = ""
    @State private var selectedTemplate: TaskIntervalTemplate?
    @State private var intervalDays = 7
    @State private var selectedCategory: TaskCategory = .other
    @State private var selectedPriority: TaskPriority = .medium
    @State private var assignToMember: FamilyMember?
    @State private var showingTemplatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Aufgabe") {
                    TextField("Titel", text: $title)
                    
                    Button {
                        showingTemplatePicker = true
                    } label: {
                        HStack {
                            Text("Vorlage wählen")
                            Spacer()
                            if selectedTemplate != nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    Picker("Priorität", selection: $selectedPriority) {
                        ForEach([TaskPriority.low, .medium, .high], id: \.self) { priority in
                            Text(priority.displayName).tag(priority)
                        }
                    }
                }
                
                Section {
                    Stepper("Alle \(intervalDays) Tage", value: $intervalDays, in: 1...365)
                    
                    Text(intervalDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Text("Intervall")
                } footer: {
                    if let template = selectedTemplate {
                        Text("Empfohlen: \(template.suggestedInterval) Tage. \(template.reasoning)")
                            .font(.caption)
                    }
                }
                
                Section("Zuweisen an") {
                    Picker("Familienmitglied", selection: $assignToMember) {
                        Text("Niemand").tag(nil as FamilyMember?)
                        ForEach(cloudKitManager.familyMembers) { member in
                            Text(member.name).tag(member as FamilyMember?)
                        }
                    }
                }
            }
            .navigationTitle("Serie erstellen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Erstellen") {
                        createTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingTemplatePicker) {
                TemplatePickerSheet(
                    templates: recurringManager.commonHouseholdTasks,
                    onSelect: { template in
                        selectedTemplate = template
                        title = template.title
                        intervalDays = template.suggestedInterval
                        selectedCategory = template.category
                        showingTemplatePicker = false
                    }
                )
            }
        }
    }
    
    private var intervalDescription: String {
        if intervalDays == 1 {
            return "Täglich"
        } else if intervalDays == 7 {
            return "Wöchentlich"
        } else if intervalDays == 14 {
            return "Alle 2 Wochen"
        } else if intervalDays == 30 {
            return "Monatlich"
        } else {
            return "Wiederholt sich automatisch"
        }
    }
    
    private func createTask() {
        let task = RecurringTask(
            title: title,
            intervalDays: intervalDays,
            category: selectedCategory,
            priority: selectedPriority,
            assignedTo: assignToMember?.userRecordID,
            assignedToName: assignToMember?.name,
            nextDueDate: Calendar.current.date(byAdding: .day, value: intervalDays, to: Date()) ?? Date()
        )
        
        recurringManager.recurringTasks.append(task)
        recurringManager.scheduleNextOccurrence(for: task)
        dismiss()
    }
}

struct TemplatePickerSheet: View {
    let templates: [TaskIntervalTemplate]
    let onSelect: (TaskIntervalTemplate) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedTemplates.keys.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                    Section(category.rawValue) {
                        ForEach(groupedTemplates[category] ?? [], id: \.title) { template in
                            Button {
                                onSelect(template)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Alle \(template.suggestedInterval) Tage • \(template.reasoning)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Vorlage wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var groupedTemplates: [TaskCategory: [TaskIntervalTemplate]] {
        Dictionary(grouping: templates, by: { $0.category })
    }
}

struct RecurringTaskDetailSheet: View {
    let task: RecurringTask
    @Environment(\.dismiss) var dismiss
    @StateObject private var recurringManager = RecurringTasksManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Details") {
                    LabeledContent("Titel", value: task.title)
                    LabeledContent("Kategorie", value: task.category.rawValue)
                    LabeledContent("Intervall", value: task.intervalDescription)
                    LabeledContent("Priorität", value: task.priority.displayName)
                    
                    if let assigned = task.assignedToName {
                        LabeledContent("Zugewiesen an", value: assigned)
                    }
                }
                
                Section("Zeitplan") {
                    LabeledContent("Nächste Fälligkeit") {
                        Text(task.nextDueDate, style: .date)
                    }
                    
                    if let lastCompleted = task.lastCompletedDate {
                        LabeledContent("Zuletzt erledigt") {
                            Text(lastCompleted, style: .date)
                        }
                    }
                    
                    LabeledContent("Status", value: task.isActive ? "Aktiv" : "Pausiert")
                }
                
                Section {
                    Button(task.isActive ? "Pausieren" : "Aktivieren") {
                        var updated = task
                        updated.isActive.toggle()
                        recurringManager.updateRecurringTask(updated)
                        dismiss()
                    }
                    .foregroundColor(task.isActive ? .orange : .green)
                    
                    Button("Löschen", role: .destructive) {
                        recurringManager.deleteRecurringTask(task)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension TaskPriority {
    var displayName: String {
        switch self {
        case .low: return "Niedrig"
        case .medium: return "Mittel"
        case .high: return "Hoch"
        }
    }
}

#Preview {
    RecurringTasksView()
        .environmentObject(CloudKitManager.shared)
}
