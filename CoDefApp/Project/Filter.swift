/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class Filter: NSObject, Codable{
    
    enum CodingKeys: String, CodingKey {
        case userId
        case onlyOpen
        case onlyOverdue
    }
    
    var userId : UUID
    var onlyOpen: Bool
    var onlyOverdue: Bool
    
    var active: Bool{
        userId != .NIL || onlyOpen || onlyOverdue
    }
    
    override init(){
        self.userId = .NIL
        onlyOpen = false
        onlyOverdue = false
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userId = try values.decodeIfPresent(UUID.self, forKey: .userId) ?? .NIL
        onlyOpen = try values.decodeIfPresent(Bool.self, forKey: .onlyOpen) ?? false
        onlyOverdue = try values.decodeIfPresent(Bool.self, forKey: .onlyOverdue) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(onlyOpen, forKey: .onlyOpen)
        try container.encode(onlyOverdue, forKey: .onlyOverdue)
    }
    
    func onlyForUserId(uuid: UUID) -> Bool{
        return userId == uuid
    }
    
    func updateUserIds(allUserIds: Array<UUID>){
        if !allUserIds.contains(userId){
            userId = .NIL
        }
    }
    
}

protocol FilterDelegate{
    func filterChanged()
}

