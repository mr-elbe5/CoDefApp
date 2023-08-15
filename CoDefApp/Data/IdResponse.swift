/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class IdResponse : Codable{
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayId
    }
    
    var id = 0
    var displayId = 0
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        displayId = try values.decodeIfPresent(Int.self, forKey: .displayId) ?? 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(displayId, forKey: .displayId)
    }
    
}
