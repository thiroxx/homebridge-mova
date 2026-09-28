import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @StateObject private var autoCompletion = AutoCompletionManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var selectedMember: FamilyMember?
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var showingSuggestions = false
    
    var filteredSuggestions: [String] {
        autoCompletion.getTaskSuggestions(for: title)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Aufgabendetails") {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("Titel", text: $title)
                            .font(.headline)
                            .onChange(of: title) { _, newValue in
                                showingSuggestions = !newValue.isEmpty
                            }
                        
                        if showingSuggestions && !filteredSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                Divider()
                                    .padding(.vertical, 8)
                                
                                ForEach(filteredSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        title = suggestion
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
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Beschreibung (optional)")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section("Priorität") {
                    Picker("Priorität", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
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
                
                Section("Zuweisen") {
                    Picker("Zuweisen an", selection: $selectedMember) {
                        Text("Niemand").tag(nil as FamilyMember?)
                        ForEach(cloudKitManager.familyMembers) { member in
                            Text(member.name).tag(member as FamilyMember?)
                        }
                    }
                }
                
                Section("Fälligkeitsdatum") {
                    Toggle("Fälligkeitsdatum setzen", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Fällig am", selection: $dueDate, displayedComponents: [.date])
                    }
                }
                
                if !autoCompletion.taskSuggestions.isEmpty {
                    Section("Häufig verwendet") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(autoCompletion.getSmartTaskSuggestions().prefix(5)), id: \.self) { suggestion in
                                    Button(action: {
                                        title = suggestion
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
            .navigationTitle("Neue Aufgabe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addTask() {
        guard let currentUser = cloudKitManager.currentUser else { return }
        
        autoCompletion.addTaskToHistory(title)
        
        let task = HouseholdTask(
            title: title,
            description: description,
            priority: priority,
            assignedTo: selectedMember?.userRecordID,
            assignedToName: selectedMember?.name,
            createdBy: currentUser.userRecordID,
            createdByName: currentUser.name,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        Task {
            await cloudKitManager.addTask(task)
            await MainActor.run {
                dismiss()
            }
        }
    }
    
    private func priorityColor(_ priority: TaskPriority) -> Color {
        switch priority.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "red": return .red
        default: return .gray
        }
    }
}

#Preview {
    AddTaskView()
        .environmentObject(CloudKitManager.shared)
}
