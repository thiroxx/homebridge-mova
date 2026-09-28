import Foundation
import UserNotifications
import CloudKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
            
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    @MainActor
    private func registerForRemoteNotifications() async {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - Task Notifications
    
    func scheduleTaskAssignedNotification(task: HouseholdTask) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Neue Aufgabe"
        content.body = "\(task.createdByName ?? "Jemand") hat dir '\(task.title)' zugewiesen"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_ASSIGNED"
        content.userInfo = ["taskId": task.id, "type": "task_assigned"]
        
        // Icon mit Priorität
        if task.priority == .urgent || task.priority == .high {
            content.interruptionLevel = .timeSensitive
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "task_\(task.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTaskDueNotification(task: HouseholdTask) {
        guard isAuthorized, let dueDate = task.dueDate else { return }
        
        // Benachrichtigung am Fälligkeitstag um 9:00 Uhr
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "Aufgabe fällig heute"
        content.body = "'\(task.title)' ist heute fällig"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "TASK_DUE"
        content.userInfo = ["taskId": task.id, "type": "task_due"]
        
        if task.priority == .urgent {
            content.interruptionLevel = .timeSensitive
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "task_due_\(task.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleTaskCompletedNotification(task: HouseholdTask, completedBy: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Aufgabe erledigt"
        content.body = "\(completedBy) hat '\(task.title)' erledigt ✓"
        content.sound = .default
        content.categoryIdentifier = "TASK_COMPLETED"
        content.userInfo = ["taskId": task.id, "type": "task_completed"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "task_completed_\(task.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleOverdueTasksNotification(count: Int) {
        guard isAuthorized, count > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Überfällige Aufgaben"
        content.body = count == 1 
            ? "1 Aufgabe ist überfällig"
            : "\(count) Aufgaben sind überfällig"
        content.sound = .default
        content.badge = NSNumber(value: count)
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "TASKS_OVERDUE"
        content.userInfo = ["count": count, "type": "tasks_overdue"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "tasks_overdue",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Shopping Notifications
    
    func scheduleShoppingItemAddedNotification(item: ShoppingItem) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        
        if item.priority == .high {
            content.title = "Dringender Einkauf"
            content.body = "\(item.addedByName ?? "Jemand") hat '\(item.name)' zur Liste hinzugefügt (Dringend)"
            content.interruptionLevel = .timeSensitive
        } else {
            content.title = "Neuer Einkaufsartikel"
            content.body = "\(item.addedByName ?? "Jemand") hat '\(item.name)' zur Liste hinzugefügt"
        }
        
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "SHOPPING_ITEM_ADDED"
        content.userInfo = ["itemId": item.id, "type": "shopping_added"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "shopping_\(item.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleUrgentShoppingItemsNotification(count: Int) {
        guard isAuthorized, count > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Dringende Einkäufe"
        content.body = count == 1
            ? "1 dringender Artikel auf der Liste"
            : "\(count) dringende Artikel auf der Liste"
        content.sound = .default
        content.badge = NSNumber(value: count)
        content.interruptionLevel = .timeSensitive
        content.categoryIdentifier = "SHOPPING_URGENT"
        content.userInfo = ["count": count, "type": "shopping_urgent"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "shopping_urgent",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleShoppingCompletedNotification(completedBy: String, itemCount: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Einkauf erledigt"
        content.body = "\(completedBy) hat \(itemCount) Artikel gekauft ✓"
        content.sound = .default
        content.categoryIdentifier = "SHOPPING_COMPLETED"
        content.userInfo = ["type": "shopping_completed"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "shopping_completed",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Family Notifications
    
    func scheduleFamilyMemberJoinedNotification(memberName: String) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Neues Familienmitglied"
        content.body = "\(memberName) ist der Familie beigetreten"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "FAMILY_JOINED"
        content.userInfo = ["type": "family_joined"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "family_joined_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Daily Summary
    
    func scheduleDailySummaryNotification(taskCount: Int, shoppingCount: Int) {
        guard isAuthorized else { return }
        
        if taskCount == 0 && shoppingCount == 0 { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Tägliche Übersicht"
        
        var bodyParts: [String] = []
        if taskCount > 0 {
            bodyParts.append("\(taskCount) offene Aufgabe\(taskCount == 1 ? "" : "n")")
        }
        if shoppingCount > 0 {
            bodyParts.append("\(shoppingCount) Einkaufsartikel")
        }
        
        content.body = bodyParts.joined(separator: " • ")
        content.sound = .default
        content.categoryIdentifier = "DAILY_SUMMARY"
        content.userInfo = ["type": "daily_summary"]
        
        // Täglich um 8:00 Uhr
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_summary",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Helper Methods
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getBadgeCount() async -> Int {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    func setBadgeCount(_ count: Int) {
        Task { @MainActor in
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
    func clearBadge() {
        setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Benachrichtigungen auch zeigen, wenn App im Vordergrund ist
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification tap
        if let type = userInfo["type"] as? String {
            switch type {
            case "task_assigned", "task_due":
                // Navigate to tasks
                NotificationCenter.default.post(name: .navigateToTasks, object: nil)
            case "shopping_added", "shopping_urgent":
                // Navigate to shopping
                NotificationCenter.default.post(name: .navigateToShopping, object: nil)
            case "family_joined":
                // Navigate to family
                NotificationCenter.default.post(name: .navigateToFamily, object: nil)
            default:
                break
            }
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToTasks = Notification.Name("navigateToTasks")
    static let navigateToShopping = Notification.Name("navigateToShopping")
    static let navigateToFamily = Notification.Name("navigateToFamily")
}
