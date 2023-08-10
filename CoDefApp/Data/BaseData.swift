/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class BaseData: Codable, Hashable, Equatable{
    
    static func == (lhs: BaseData, rhs: BaseData) -> Bool {
        return lhs.uuid==rhs.uuid
    }
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case cloudId
        case creationDate
        case creatorId
        case changeDate
        case changerId
    }
    
    var uuid : UUID
    var cloudId = 0
    var creationDate : Date
    var changeDate : Date
    var creatorId = UUID.NIL
    var changerId = UUID.NIL
    
    var isNew: Bool
    
    var creatorCloudId: Int{
        AppData.shared.users.cloudId(ofUserWithId: creatorId)
    }
    
    var creatorName: String{
        if creatorId == UserData.anonymousUserId{
            return UserData.anonymousUser.name
        }
        return AppData.shared.users.name(ofUserWithId: creatorId)
    }
    
    var changerCloudId: Int{
        AppData.shared.users.cloudId(ofUserWithId: changerId)
    }
    
    var synchronized: Bool {
        cloudId == 0
    }
    
    init(){
        uuid = UUID()
        cloudId = 0
        creatorId = CurrentUser.instance.uuid
        changerId = creatorId
        creationDate = Date()
        changeDate = creationDate
        isNew = true
    }
    
    // for static users
    init(uuid: UUID){
        self.uuid = uuid
        cloudId = 0
        creatorId = UserData.anonymousUserId
        changerId = creatorId
        creationDate = Date()
        changeDate = creationDate
        isNew = false
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(UUID.self, forKey: .uuid)
        cloudId = try values.decodeIfPresent(Int.self, forKey: .cloudId) ?? 0
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
        changeDate = try values.decodeIfPresent(Date.self, forKey: .changeDate) ?? creationDate
        creatorId = try values.decodeIfPresent(UUID.self, forKey: .creatorId) ?? .NIL
        changerId = try values.decodeIfPresent(UUID.self, forKey: .changerId) ?? .NIL
        isNew = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(cloudId, forKey: .cloudId)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(changeDate, forKey: .changeDate)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(changerId, forKey: .changerId)
    }
    
    func changed(){
        changerId = CurrentUser.instance.uuid
        changeDate = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    func asDictionary() -> Dictionary<String,String>{
        var dict = Dictionary<String,String>()
        dict["id"]=uuid.uuidString
        dict["cloudId"]=String(cloudId)
        dict["creatorId"]=creatorId.uuidString
        dict["creatorCloudId"]=String(creatorCloudId)
        dict["changerId"]=changerId.uuidString
        dict["changerCloudId"]=String(changerCloudId)
        dict["creationDate"]=creationDate.isoString()
        dict["changeDate"]=changeDate.isoString()
        return dict
    }
    
    func saveData(){
        AppData.shared.save()
    }
    
    func hasUserEditRights(userId: UUID) -> Bool{
        userId == creatorId || userId == changerId
    }
 
}

