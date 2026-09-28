import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var selectedMember: FamilyMember?
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Aufgabendetails") {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    
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
