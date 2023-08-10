/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class IdResponse : Codable{
    
    enum CodingKeys: String, CodingKey {
        case id
        case uuid
        case displayId
    }
    
    var id = 0
    var uuid : UUID = .NIL
    var displayId = 0
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        if let str = try values.decodeIfPresent(String.self, forKey: .uuid), let uuid = UUID(uuidString: str){
            self.uuid =  uuid
        }
        else{
            uuid = .NIL
        }
        displayId = try values.decodeIfPresent(Int.self, forKey: .displayId) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(displayId, forKey: .displayId)
    }
    
}
