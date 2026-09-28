import SwiftUI

struct TasksView: View {
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "Alle"
        case active = "Aktiv"
        case completed = "Erledigt"
        case myTasks = "Meine Aufgaben"
    }
    
    var filteredTasks: [HouseholdTask] {
        let tasks = cloudKitManager.tasks
        
        switch selectedFilter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        case .myTasks:
            return tasks.filter { $0.assignedTo == cloudKitManager.currentUser?.userRecordID }
        }
    }
    
    var sortedTasks: [HouseholdTask] {
        filteredTasks.sorted { task1, task2 in
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            if task1.priority.sortOrder != task2.priority.sortOrder {
                return task1.priority.sortOrder < task2.priority.sortOrder
            }
            return task1.createdAt > task2.createdAt
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                filterBar
                
                if sortedTasks.isEmpty {
                    emptyState
                } else {
                    tasksList
                }
            }
            .navigationTitle("Aufgaben")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .refreshable {
                await cloudKitManager.fetchTasks()
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter,
                        action: { selectedFilter = filter }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    private var tasksList: some View {
        List {
            ForEach(sortedTasks) { task in
                TaskRowView(task: task)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task {
                                await cloudKitManager.deleteTask(task)
                            }
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Keine Aufgaben")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Füge eine neue Aufgabe hinzu")
                .font(.body)
                .foregroundColor(.secondary)
            
            Button(action: { showingAddTask = true }) {
                Label("Neue Aufgabe", systemImage: "plus")
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

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

#Preview {
    TasksView()
        .environmentObject(CloudKitManager.shared)
}
