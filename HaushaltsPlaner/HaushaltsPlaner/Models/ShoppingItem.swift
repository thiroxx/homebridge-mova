import Foundation
import CloudKit

struct ShoppingItem: Identifiable, Codable {
    var id: String
    var name: String
    var quantity: String
    var category: ShoppingCategory
    var isPurchased: Bool
    var addedBy: String
    var addedByName: String?
    var addedAt: Date
    var purchasedAt: Date?
    var recordName: String?
    
    init(
        id: String = UUID().uuidString,
        name: String,
        quantity: String = "1",
        category: ShoppingCategory = .other,
        isPurchased: Bool = false,
        addedBy: String,
        addedByName: String? = nil,
        addedAt: Date = Date(),
        purchasedAt: Date? = nil,
        recordName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.isPurchased = isPurchased
        self.addedBy = addedBy
        self.addedByName = addedByName
        self.addedAt = addedAt
        self.purchasedAt = purchasedAt
        self.recordName = recordName
    }
    
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        if let recordName = recordName {
            let recordID = CKRecord.ID(recordName: recordName)
            record = CKRecord(recordType: "ShoppingItem", recordID: recordID)
        } else {
            record = CKRecord(recordType: "ShoppingItem")
        }
        
        record["id"] = id as CKRecordValue
        record["name"] = name as CKRecordValue
        record["quantity"] = quantity as CKRecordValue
        record["category"] = category.rawValue as CKRecordValue
        record["isPurchased"] = (isPurchased ? 1 : 0) as CKRecordValue
        record["addedBy"] = addedBy as CKRecordValue
        record["addedAt"] = addedAt as CKRecordValue
        
        if let addedByName = addedByName {
            record["addedByName"] = addedByName as CKRecordValue
        }
        if let purchasedAt = purchasedAt {
            record["purchasedAt"] = purchasedAt as CKRecordValue
        }
        
        return record
    }
    
    static func fromCKRecord(_ record: CKRecord) -> ShoppingItem? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let quantity = record["quantity"] as? String,
              let categoryRaw = record["category"] as? String,
              let category = ShoppingCategory(rawValue: categoryRaw),
              let isPurchasedInt = record["isPurchased"] as? Int,
              let addedBy = record["addedBy"] as? String,
              let addedAt = record["addedAt"] as? Date else {
            return nil
        }
        
        return ShoppingItem(
            id: id,
            name: name,
            quantity: quantity,
            category: category,
            isPurchased: isPurchasedInt == 1,
            addedBy: addedBy,
            addedByName: record["addedByName"] as? String,
            addedAt: addedAt,
            purchasedAt: record["purchasedAt"] as? Date,
            recordName: record.recordID.recordName
        )
    }
}

enum ShoppingCategory: String, Codable, CaseIterable {
    case groceries = "Lebensmittel"
    case household = "Haushalt"
    case personal = "Körperpflege"
    case other = "Sonstiges"
    
    var icon: String {
        switch self {
        case .groceries: return "🛒"
        case .household: return "🏠"
        case .personal: return "💄"
        case .other: return "📦"
        }
    }
}
