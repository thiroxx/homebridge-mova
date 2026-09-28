import Foundation
import CloudKit

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Niedrig"
    case medium = "Mittel"
    case high = "Hoch"
    case urgent = "Dringend"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .urgent: return 0
        case .high: return 1
        case .medium: return 2
        case .low: return 3
        }
    }
}

struct HouseholdTask: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var priority: TaskPriority
    var isCompleted: Bool
    var assignedTo: String?
    var assignedToName: String?
    var createdBy: String
    var createdByName: String?
    var createdAt: Date
    var dueDate: Date?
    var completedAt: Date?
    var recordName: String?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        isCompleted: Bool = false,
        assignedTo: String? = nil,
        assignedToName: String? = nil,
        createdBy: String,
        createdByName: String? = nil,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        completedAt: Date? = nil,
        recordName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.isCompleted = isCompleted
        self.assignedTo = assignedTo
        self.assignedToName = assignedToName
        self.createdBy = createdBy
        self.createdByName = createdByName
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.completedAt = completedAt
        self.recordName = recordName
    }
    
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordName = recordName {
            let recordID = CKRecord.ID(recordName: recordName)
            record = CKRecord(recordType: "HouseholdTask", recordID: recordID)
        } else {
            record = CKRecord(recordType: "HouseholdTask")
        }
        
        record["id"] = id as CKRecordValue
        record["title"] = title as CKRecordValue
        record["taskDescription"] = description as CKRecordValue
        record["priority"] = priority.rawValue as CKRecordValue
        record["isCompleted"] = (isCompleted ? 1 : 0) as CKRecordValue
        record["createdBy"] = createdBy as CKRecordValue
        record["createdAt"] = createdAt as CKRecordValue
        
        if let assignedTo = assignedTo {
            record["assignedTo"] = assignedTo as CKRecordValue
        }
        if let assignedToName = assignedToName {
            record["assignedToName"] = assignedToName as CKRecordValue
        }
        if let createdByName = createdByName {
            record["createdByName"] = createdByName as CKRecordValue
        }
        if let dueDate = dueDate {
            record["dueDate"] = dueDate as CKRecordValue
        }
        if let completedAt = completedAt {
            record["completedAt"] = completedAt as CKRecordValue
        }
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> HouseholdTask? {
        guard let id = record["id"] as? String,
              let title = record["title"] as? String,
              let description = record["taskDescription"] as? String,
              let priorityRaw = record["priority"] as? String,
              let priority = TaskPriority(rawValue: priorityRaw),
              let isCompletedInt = record["isCompleted"] as? Int,
              let createdBy = record["createdBy"] as? String,
              let createdAt = record["createdAt"] as? Date else {
            return nil
        }
        
        return HouseholdTask(
            id: id,
            title: title,
            description: description,
            priority: priority,
            isCompleted: isCompletedInt == 1,
            assignedTo: record["assignedTo"] as? String,
            assignedToName: record["assignedToName"] as? String,
            createdBy: createdBy,
            createdByName: record["createdByName"] as? String,
            createdAt: createdAt,
            dueDate: record["dueDate"] as? Date,
            completedAt: record["completedAt"] as? Date,
            recordName: record.recordID.recordName
        )
    }
}
