import SwiftUI
import MapKit

struct SmartInsightsView: View {
    @StateObject private var aiManager = AIInsightsManager.shared
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Insights Header
                    if !aiManager.taskSuggestions.isEmpty || !aiManager.shoppingPredictions.isEmpty {
                        headerSection
                    }
                    
                    // Shopping Predictions
                    if !aiManager.shoppingPredictions.isEmpty {
                        shoppingPredictionsSection
                    }
                    
                    // Task Suggestions
                    if !aiManager.taskSuggestions.isEmpty {
                        taskSuggestionsSection
                    }
                    
                    // Empty State
                    if aiManager.taskSuggestions.isEmpty && aiManager.shoppingPredictions.isEmpty {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("Smart Insights")
            .onAppear {
                refreshInsights()
            }
            .refreshable {
                refreshInsights()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("KI-Vorschläge")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text("Basierend auf deinen Mustern und dem aktuellen Wetter")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var shoppingPredictionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🛒 Einkaufs-Vorschläge")
                .font(.headline)
            
            ForEach(aiManager.shoppingPredictions) { prediction in
                ShoppingPredictionCard(prediction: prediction) {
                    addToShoppingList(prediction)
                }
            }
        }
    }
    
    private var taskSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 Aufgaben-Vorschläge")
                .font(.headline)
            
            ForEach(aiManager.taskSuggestions) { suggestion in
                TaskSuggestionCard(suggestion: suggestion) {
                    createTask(from: suggestion)
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("Noch keine Insights")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Die KI lernt von deinen Mustern.\nNutze die App regelmäßig für intelligente Vorschläge!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private func refreshInsights() {
        Task {
            await aiManager.analyzeTaskPatterns(
                tasks: cloudKitManager.tasks,
                location: LocationManager.shared.currentLocation
            )
            aiManager.analyzeShoppingItems(cloudKitManager.shoppingItems)
        }
    }
    
    private func addToShoppingList(_ prediction: ShoppingPrediction) {
        guard let currentUser = cloudKitManager.currentUser else { return }
        
        let item = ShoppingItem(
            name: prediction.itemName,
            quantity: "1",
            category: .groceries,
            priority: prediction.urgency == .now ? .high : .low,
            addedBy: currentUser.userRecordID,
            addedByName: currentUser.name
        )
        
        Task {
            await cloudKitManager.addShoppingItem(item)
        }
    }
    
    private func createTask(from suggestion: TaskSuggestion) {
        guard let currentUser = cloudKitManager.currentUser else { return }
        
        let priority: TaskPriority
        switch suggestion.priority {
        case .urgent: priority = .urgent
        case .high: priority = .high
        case .medium: priority = .medium
        case .low: priority = .low
        }
        
        let task = HouseholdTask(
            title: suggestion.title,
            description: suggestion.reason,
            priority: priority,
            createdBy: currentUser.userRecordID,
            createdByName: currentUser.name,
            dueDate: suggestion.suggestedDate
        )
        
        Task {
            await cloudKitManager.addTask(task)
        }
    }
}

struct ShoppingPredictionCard: View {
    let prediction: ShoppingPrediction
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(prediction.itemName)
                        .font(.headline)
                    
                    Text(prediction.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                urgencyBadge
            }
            
            HStack {
                confidenceIndicator
                
                Spacer()
                
                Button(action: onAdd) {
                    Label("Hinzufügen", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var urgencyBadge: some View {
        let (text, color): (String, Color) = {
            switch prediction.urgency {
            case .now: return ("Jetzt!", .red)
            case .soon: return ("Bald", .orange)
            case .upcoming: return ("Demnächst", .blue)
            }
        }()
        
        return Text(text)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
    
    private var confidenceIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "chart.bar.fill")
                .font(.caption)
            Text("\(Int(prediction.confidence * 100))% sicher")
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

struct TaskSuggestionCard: View {
    let suggestion: TaskSuggestion
    let onCreate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                typeIcon
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.title)
                        .font(.headline)
                    
                    Text(suggestion.reason)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack {
                priorityBadge
                
                Spacer()
                
                Button(action: onCreate) {
                    Label("Erstellen", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var typeIcon: some View {
        let (icon, color): (String, Color) = {
            switch suggestion.type {
            case .weatherBased: return ("cloud.sun.fill", .blue)
            case .patternBased: return ("chart.line.uptrend.xyaxis", .purple)
            case .seasonal: return ("leaf.fill", .green)
            case .overdue: return ("exclamationmark.triangle.fill", .red)
            }
        }()
        
        return Image(systemName: icon)
            .font(.title3)
            .foregroundColor(color)
    }
    
    private var priorityBadge: some View {
        let (text, color): (String, Color) = {
            switch suggestion.priority {
            case .urgent: return ("Dringend", .red)
            case .high: return ("Hoch", .orange)
            case .medium: return ("Mittel", .blue)
            case .low: return ("Niedrig", .gray)
            }
        }()
        
        return Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color)
            .cornerRadius(6)
    }
}

#Preview {
    SmartInsightsView()
        .environmentObject(CloudKitManager.shared)
}
