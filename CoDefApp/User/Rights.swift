/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class Rights: Codable{
    
    static let read: Int = 0
    static let projectEdit: Int = 1
    static let globalEdit: Int = 2
    static let system: Int = 4
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    var value: Int
    
    init(projectEdit: Bool = false, globalEdit: Bool = false, system: Bool = false){
        value = 0 + (projectEdit ? Rights.projectEdit : 0) + (globalEdit ? Rights.globalEdit : 0) + (system ? Rights.system : 0)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decodeIfPresent(Int.self, forKey: .value) ?? Rights.read
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
    
    var hasProjectEditRight: Bool{
        hasGlobalEditRight || (value & Rights.projectEdit) == Rights.projectEdit
    }
    
    var hasGlobalEditRight: Bool{
        (value & Rights.globalEdit) == Rights.globalEdit
    }
    
    var hasSystemRight: Bool{
        (value & Rights.system) == Rights.system
    }
    
}
