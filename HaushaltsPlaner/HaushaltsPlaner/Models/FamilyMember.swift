import Foundation
import CloudKit

struct FamilyMember: Identifiable, Codable {
    var id: String
    var userRecordID: String
    var name: String
    var email: String?
    var isOwner: Bool
    var joinedAt: Date
    var color: String
    
    init(
        id: String = UUID().uuidString,
        userRecordID: String,
        name: String,
        email: String? = nil,
        isOwner: Bool = false,
        joinedAt: Date = Date(),
        color: String = "blue"
    ) {
        self.id = id
        self.userRecordID = userRecordID
        self.name = name
        self.email = email
        self.isOwner = isOwner
        self.joinedAt = joinedAt
        self.color = color
    }
    
    static let colors = ["blue", "green", "orange", "purple", "pink", "red", "indigo", "teal"]
}
