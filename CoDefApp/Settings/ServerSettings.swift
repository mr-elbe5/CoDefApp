/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ServerSettings : Codable{
    
    enum CodingKeys: String, CodingKey {
        case country
        case timeZoneName
        case meteoStatKey
    }
    
    var country = "de"
    var timeZoneName = ""
    var meteoStatKey = ""
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        country = try values.decodeIfPresent(String.self, forKey: .country) ?? ""
        timeZoneName = try values.decodeIfPresent(String.self, forKey: .timeZoneName) ?? ""
        meteoStatKey = try values.decodeIfPresent(String.self, forKey: .meteoStatKey) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(country, forKey: .country)
        try container.encode(timeZoneName, forKey: .timeZoneName)
        try container.encode(meteoStatKey, forKey: .meteoStatKey)
    }
    
}
