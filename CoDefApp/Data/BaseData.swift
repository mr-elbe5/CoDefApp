/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class BaseData: Codable, Hashable, Equatable{
    
    static func == (lhs: BaseData, rhs: BaseData) -> Bool {
        return lhs.id==rhs.id
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case cloudId
        case creationDate
        case creatorId
        case creatorName
        case changeDate
        case changerId
        case changerName
        case synchronized
        case isNew
    }
    
    var id : Int
    var cloudId: Int
    var creationDate : Date
    var creatorId = 0
    var creatorName = ""
    var changeDate : Date
    var changerId = 0
    var changerName = ""
    var synchronized: Bool
    var isNew: Bool
    
    init(){
        id = AppState.shared.nextId
        cloudId = 0
        creationDate = Date()
        creatorId = AppState.shared.currentUser.id
        creatorName = AppState.shared.currentUser.name
        changeDate = creationDate
        changerId = creatorId
        changerName = creatorName
        synchronized = false
        isNew = true
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        cloudId = try values.decode(Int.self, forKey: .cloudId)
        creationDate = try values.decodeIfPresent(Date.self, forKey: .creationDate) ?? Date()
        creatorId = try values.decodeIfPresent(Int.self, forKey: .creatorId) ?? 0
        creatorName = try values.decodeIfPresent(String.self, forKey: .creatorName) ?? ""
        changeDate = try values.decodeIfPresent(Date.self, forKey: .changeDate) ?? creationDate
        changerId = try values.decodeIfPresent(Int.self, forKey: .changerId) ?? 0
        changerName = try values.decodeIfPresent(String.self, forKey: .changerName) ?? ""
        synchronized = try values.decodeIfPresent(Bool.self, forKey: .synchronized) ?? false
        isNew = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(creatorName, forKey: .creatorName)
        try container.encode(changeDate, forKey: .changeDate)
        try container.encode(changerId, forKey: .changerId)
        try container.encode(changerName, forKey: .changerName)
        try container.encode(synchronized, forKey: .synchronized)
    }
    
    func changed(){
        changerId = AppState.shared.currentUser.id
        changerName = AppState.shared.currentUser.name
        changeDate = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func asDictionary() -> Dictionary<String,String>{
        var dict = Dictionary<String,String>()
        dict["id"]=String(id)
        dict["creatorId"]=String(creatorId)
        dict["changerId"]=String(changerId)
        dict["creationDate"]=creationDate.isoString()
        dict["changeDate"]=changeDate.isoString()
        dict["synchronized"]=String(synchronized)
        return dict
    }
    
    func saveData(){
        AppData.shared.save()
    }
 
}

