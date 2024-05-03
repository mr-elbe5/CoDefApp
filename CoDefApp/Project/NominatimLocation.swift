/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class NominatimLocation : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case displayName
    }
    
    var latitude: Double = 0
    var longitude: Double = 0
    var displayName: String = ""
    
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        latitude = try values.decodeIfPresent(Double.self, forKey: .lat) ?? 0
        longitude = try values.decodeIfPresent(Double.self, forKey: .lon) ?? 0
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? ""
    }
    
}
