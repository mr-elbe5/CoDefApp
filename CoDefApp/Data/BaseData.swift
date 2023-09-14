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
        case isOnServer
        case creationDate
        case creatorId
        case creatorName
        case changeDate
        case changerId
        case changerName
    }
    
    var id : Int
    var isOnServer: Bool
    var creationDate : Date
    var creatorId = 0
    var creatorName = ""
    var changeDate : Date
    var changerId = 0
    var changerName = ""
    
    init(){
        id = AppState.shared.nextId
        isOnServer = false
        creationDate = Date()
        creatorId = AppState.shared.currentUser.id
        creatorName = AppState.shared.currentUser.name
        changeDate = creationDate
        changerId = creatorId
        changerName = creatorName
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        isOnServer = try values.decodeIfPresent(Bool.self, forKey: .isOnServer) ?? false
        var date = try values.decodeIfPresent(String.self, forKey: .creationDate)
        creationDate = date?.ISO8601Date() ?? Date()
        creatorId = try values.decodeIfPresent(Int.self, forKey: .creatorId) ?? 0
        creatorName = try values.decodeIfPresent(String.self, forKey: .creatorName) ?? ""
        date = try values.decodeIfPresent(String.self, forKey: .changeDate)
        changeDate = date?.ISO8601Date() ?? creationDate
        changerId = try values.decodeIfPresent(Int.self, forKey: .changerId) ?? 0
        changerName = try values.decodeIfPresent(String.self, forKey: .changerName) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isOnServer, forKey: .isOnServer)
        try container.encode(creationDate.isoString(), forKey: .creationDate)
        try container.encode(creatorId, forKey: .creatorId)
        try container.encode(creatorName, forKey: .creatorName)
        try container.encode(changeDate.isoString(), forKey: .changeDate)
        try container.encode(changerId, forKey: .changerId)
        try container.encode(changerName, forKey: .changerName)
    }
    
    func changed(){
        changerId = AppState.shared.currentUser.id
        changerName = AppState.shared.currentUser.name
        changeDate = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func saveData(){
        AppData.shared.save()
    }
    
    // sync
    
    func synchronizeFrom(_ fromData: BaseData) async{
        creationDate = fromData.creationDate
        creatorId = fromData.creatorId
        creatorName = fromData.creatorName
        changeDate = fromData.changeDate
        changerId = fromData.creatorId
        changerName = fromData.changerName
    }
    
    var uploadParams : Dictionary<String,String>{
        var dict = Dictionary<String,String>()
        dict["id"]=String(id)
        dict["creatorId"]=String(creatorId)
        dict["changerId"]=String(changerId)
        dict["creationDate"]=creationDate.isoString()
        dict["changeDate"]=changeDate.isoString()
        return dict
    }
 
}

typealias BaseDataArray<T: BaseData> = Array<T>

extension BaseDataArray{
    
    func getBaseData(id: Int) -> BaseData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
    mutating func sortById(){
        self = self.sorted {
            $0.id < $1.id
        }
    }
    
}
