import Foundation
import CloudKit
import Combine

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    @Published var tasks: [HouseholdTask] = []
    @Published var shoppingItems: [ShoppingItem] = []
    @Published var familyMembers: [FamilyMember] = []
    @Published var currentUser: FamilyMember?
    @Published var isInitialized = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let sharedDatabase: CKDatabase
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        container = CKContainer(identifier: "iCloud.com.haushaltsplaner.app")
        privateDatabase = container.privateCloudDatabase
        sharedDatabase = container.sharedCloudDatabase
    }
    
    func initialize() {
        guard !isInitialized else { return }
        
        Task {
            do {
                try await requestPermissions()
                try await fetchUserIdentity()
                try await setupSubscriptions()
                await fetchAllData()
                
                await MainActor.run {
                    isInitialized = true
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func requestPermissions() async throws {
        let status = try await container.accountStatus()
        
        switch status {
        case .available:
            break
        case .noAccount:
            throw CloudKitError.noAccount
        case .restricted:
            throw CloudKitError.restricted
        case .couldNotDetermine:
            throw CloudKitError.couldNotDetermine
        case .temporarilyUnavailable:
            throw CloudKitError.temporarilyUnavailable
        @unknown default:
            throw CloudKitError.unknown
        }
    }
    
    private func fetchUserIdentity() async throws {
        let userRecordID = try await container.userRecordID()
        let recordIDString = userRecordID.recordName
        
        let userIdentity = try await container.userIdentity(forUserRecordID: userRecordID)
        let name = userIdentity?.nameComponents?.formatted() ?? "Ich"
        
        let existingMember = familyMembers.first { $0.userRecordID == recordIDString }
        
        if existingMember == nil {
            let newMember = FamilyMember(
                userRecordID: recordIDString,
                name: name,
                isOwner: true,
                color: FamilyMember.colors.randomElement() ?? "blue"
            )
            
            await MainActor.run {
                self.currentUser = newMember
                self.familyMembers.append(newMember)
            }
        } else {
            await MainActor.run {
                self.currentUser = existingMember
            }
        }
    }
    
    private func setupSubscriptions() async throws {
        try await setupTaskSubscription()
        try await setupShoppingSubscription()
    }
    
    private func setupTaskSubscription() async throws {
        let subscription = CKQuerySubscription(
            recordType: "HouseholdTask",
            predicate: NSPredicate(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await sharedDatabase.save(subscription)
    }
    
    private func setupShoppingSubscription() async throws {
        let subscription = CKQuerySubscription(
            recordType: "ShoppingItem",
            predicate: NSPredicate(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        try await sharedDatabase.save(subscription)
    }
    
    func fetchAllData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchTasks() }
            group.addTask { await self.fetchShoppingItems() }
        }
    }
    
    func fetchTasks() async {
        let query = CKQuery(recordType: "HouseholdTask", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let result = try await sharedDatabase.records(matching: query)
            let tasks = result.matchResults.compactMap { try? $0.1.get() }
                .compactMap { HouseholdTask.fromCKRecord($0) }
            
            await MainActor.run {
                self.tasks = tasks
            }
        } catch {
            await handleError(error)
        }
    }
    
    func fetchShoppingItems() async {
        let query = CKQuery(recordType: "ShoppingItem", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
        
        do {
            let result = try await sharedDatabase.records(matching: query)
            let items = result.matchResults.compactMap { try? $0.1.get() }
                .compactMap { ShoppingItem.fromCKRecord($0) }
            
            await MainActor.run {
                self.shoppingItems = items
            }
        } catch {
            await handleError(error)
        }
    }
    
    func addTask(_ task: HouseholdTask) async {
        let record = task.toCKRecord()
        
        do {
            _ = try await sharedDatabase.save(record)
            await fetchTasks()
            
            // Benachrichtigung wenn Aufgabe zugewiesen wurde
            if let assignedTo = task.assignedTo,
               assignedTo != currentUser?.userRecordID {
                NotificationManager.shared.scheduleTaskAssignedNotification(task: task)
            }
            
            // Benachrichtigung für Fälligkeitsdatum
            if task.dueDate != nil {
                NotificationManager.shared.scheduleTaskDueNotification(task: task)
            }
        } catch {
            await handleError(error)
        }
    }
    
    func updateTask(_ task: HouseholdTask) async {
        let record = task.toCKRecord()
        
        do {
            _ = try await sharedDatabase.save(record)
            await fetchTasks()
            
            // Benachrichtigung wenn Aufgabe erledigt wurde
            if task.isCompleted, let completedByName = task.createdByName {
                NotificationManager.shared.scheduleTaskCompletedNotification(
                    task: task,
                    completedBy: completedByName
                )
                
                // Aufgabe für AI und Recurring Tasks aufzeichnen
                AIInsightsManager.shared.recordTaskCompletion(task: task)
                
                // Prüfe ob diese Aufgabe Teil einer Serie ist
                let recurringManager = RecurringTasksManager.shared
                if let recurringTask = recurringManager.recurringTasks.first(where: { 
                    $0.title == task.title && $0.isActive 
                }) {
                    // Plane nächste Occurrence
                    recurringManager.scheduleNextOccurrence(for: recurringTask)
                }
            }
        } catch {
            await handleError(error)
        }
    }
    
    func deleteTask(_ task: HouseholdTask) async {
        guard let recordName = task.recordName else { return }
        let recordID = CKRecord.ID(recordName: recordName)
        
        do {
            _ = try await sharedDatabase.deleteRecord(withID: recordID)
            await fetchTasks()
        } catch {
            await handleError(error)
        }
    }
    
    func addShoppingItem(_ item: ShoppingItem) async {
        let record = item.toCKRecord()
        
        do {
            _ = try await sharedDatabase.save(record)
            await fetchShoppingItems()
            
            // Benachrichtigung für neuen Einkaufsartikel
            if item.addedBy != currentUser?.userRecordID {
                NotificationManager.shared.scheduleShoppingItemAddedNotification(item: item)
            }
            
            // Prüfe dringende Artikel
            let urgentCount = shoppingItems.filter { 
                $0.priority == .high && !$0.isPurchased 
            }.count
            
            if urgentCount > 0 {
                NotificationManager.shared.scheduleUrgentShoppingItemsNotification(count: urgentCount)
            }
        } catch {
            await handleError(error)
        }
    }
    
    func updateShoppingItem(_ item: ShoppingItem) async {
        let record = item.toCKRecord()
        
        do {
            _ = try await sharedDatabase.save(record)
            await fetchShoppingItems()
        } catch {
            await handleError(error)
        }
    }
    
    func deleteShoppingItem(_ item: ShoppingItem) async {
        guard let recordName = item.recordName else { return }
        let recordID = CKRecord.ID(recordName: recordName)
        
        do {
            _ = try await sharedDatabase.deleteRecord(withID: recordID)
            await fetchShoppingItems()
        } catch {
            await handleError(error)
        }
    }
    
    func shareWithFamily() async throws -> CKShare {
        let rootRecord = CKRecord(recordType: "FamilyShare")
        rootRecord["name"] = "Familie" as CKRecordValue
        
        let share = CKShare(rootRecord: rootRecord)
        share[CKShare.SystemFieldKey.title] = "Haushaltsplaner" as CKRecordValue
        share.publicPermission = .none
        
        let records = [rootRecord, share]
        _ = try await sharedDatabase.modifyRecords(saving: records, deleting: [])
        
        return share
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
}

enum CloudKitError: LocalizedError {
    case noAccount
    case restricted
    case couldNotDetermine
    case temporarilyUnavailable
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noAccount:
            return "Kein iCloud-Konto gefunden. Bitte melden Sie sich in den Einstellungen bei iCloud an."
        case .restricted:
            return "iCloud-Zugriff ist eingeschränkt."
        case .couldNotDetermine:
            return "iCloud-Status konnte nicht ermittelt werden."
        case .temporarilyUnavailable:
            return "iCloud ist vorübergehend nicht verfügbar."
        case .unknown:
            return "Ein unbekannter Fehler ist aufgetreten."
        }
    }
}
