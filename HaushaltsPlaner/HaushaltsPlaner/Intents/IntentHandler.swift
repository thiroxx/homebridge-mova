import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        if intent is AddTaskIntent {
            return AddTaskIntentHandler()
        } else if intent is AddShoppingItemIntent {
            return AddShoppingItemIntentHandler()
        }
        return self
    }
}

class AddTaskIntentHandler: NSObject, AddTaskIntentHandling {
    func handle(intent: AddTaskIntent, completion: @escaping (AddTaskIntentResponse) -> Void) {
        guard let taskTitle = intent.taskTitle, !taskTitle.isEmpty else {
            completion(AddTaskIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        let priority = mapPriority(intent.priority)
        
        Task {
            let cloudKitManager = CloudKitManager.shared
            
            guard let currentUser = cloudKitManager.currentUser else {
                completion(AddTaskIntentResponse(code: .failure, userActivity: nil))
                return
            }
            
            let task = HouseholdTask(
                title: taskTitle,
                description: intent.taskDescription ?? "",
                priority: priority,
                createdBy: currentUser.userRecordID,
                createdByName: currentUser.name
            )
            
            await cloudKitManager.addTask(task)
            
            let response = AddTaskIntentResponse(code: .success, userActivity: nil)
            response.taskTitle = taskTitle
            completion(response)
        }
    }
    
    func resolveTaskTitle(for intent: AddTaskIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let title = intent.taskTitle, !title.isEmpty {
            completion(INStringResolutionResult.success(with: title))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    private func mapPriority(_ priority: TaskPriorityEnum) -> TaskPriority {
        switch priority {
        case .low: return .low
        case .medium: return .medium
        case .high: return .high
        case .urgent: return .urgent
        case .unknown: return .medium
        }
    }
}

class AddShoppingItemIntentHandler: NSObject, AddShoppingItemIntentHandling {
    func handle(intent: AddShoppingItemIntent, completion: @escaping (AddShoppingItemIntentResponse) -> Void) {
        guard let itemName = intent.itemName, !itemName.isEmpty else {
            completion(AddShoppingItemIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        let quantity = intent.quantity ?? "1"
        let category = mapCategory(intent.category)
        
        Task {
            let cloudKitManager = CloudKitManager.shared
            
            guard let currentUser = cloudKitManager.currentUser else {
                completion(AddShoppingItemIntentResponse(code: .failure, userActivity: nil))
                return
            }
            
            let item = ShoppingItem(
                name: itemName,
                quantity: quantity,
                category: category,
                addedBy: currentUser.userRecordID,
                addedByName: currentUser.name
            )
            
            await cloudKitManager.addShoppingItem(item)
            
            let response = AddShoppingItemIntentResponse(code: .success, userActivity: nil)
            response.itemName = itemName
            completion(response)
        }
    }
    
    func resolveItemName(for intent: AddShoppingItemIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let name = intent.itemName, !name.isEmpty {
            completion(INStringResolutionResult.success(with: name))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    private func mapCategory(_ category: ShoppingCategoryEnum) -> ShoppingCategory {
        switch category {
        case .groceries: return .groceries
        case .household: return .household
        case .personal: return .personal
        case .other: return .other
        case .unknown: return .other
        }
    }
}
