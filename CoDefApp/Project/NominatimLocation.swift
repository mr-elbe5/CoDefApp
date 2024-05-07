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
        case display_name
    }
    
    var latitude: Double = 0
    var longitude: Double = 0
    var displayName: String = ""
    
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let latString = try values.decodeIfPresent(String.self, forKey: .lat){
            latitude = Double(latString) ?? 0
        }
        if let lonString = try values.decodeIfPresent(String.self, forKey: .lon){
            longitude = Double(lonString) ?? 0
        }
        displayName = try values.decodeIfPresent(String.self, forKey: .display_name) ?? ""
    }
    
}
