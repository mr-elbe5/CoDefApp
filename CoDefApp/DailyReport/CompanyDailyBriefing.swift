/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class CompanyDailyBriefing: Codable{
    
    enum CodingKeys: String, CodingKey {
        case companyId
        case activity
        case briefing
    }
    
    var  companyId: Int = 0
    var activity: String = ""
    var briefing: String = ""
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        companyId = try values.decode(Int.self, forKey: .companyId)
        activity = try values.decodeIfPresent(String.self, forKey: .activity) ?? ""
        briefing = try values.decodeIfPresent(String.self, forKey: .briefing) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(companyId, forKey: .companyId)
        try container.encode(activity, forKey: .activity)
        try container.encode(briefing, forKey: .briefing)
    }
    
}
