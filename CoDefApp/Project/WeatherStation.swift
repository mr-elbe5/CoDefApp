/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class WeatherStation : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case id
    }
    
    var id: String = ""
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
    }
    
}

class WeatherStationList : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    var data = Array<WeatherStation>()
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(Array<WeatherStation>.self, forKey: .data) ?? Array<WeatherStation>()
    }
    
}
