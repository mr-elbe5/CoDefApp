/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class Filter: NSObject, Codable{
    
    enum CodingKeys: String, CodingKey {
        case companyId
        case onlyOpen
        case onlyOverdue
    }
    
    var companyId : Int
    var onlyOpen: Bool
    var onlyOverdue: Bool
    
    var active: Bool{
        companyId != 0 || onlyOpen || onlyOverdue
    }
    
    override init(){
        self.companyId = 0
        onlyOpen = false
        onlyOverdue = false
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        companyId = try values.decodeIfPresent(Int.self, forKey: .companyId) ?? 0
        onlyOpen = try values.decodeIfPresent(Bool.self, forKey: .onlyOpen) ?? false
        onlyOverdue = try values.decodeIfPresent(Bool.self, forKey: .onlyOverdue) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(companyId, forKey: .companyId)
        try container.encode(onlyOpen, forKey: .onlyOpen)
        try container.encode(onlyOverdue, forKey: .onlyOverdue)
    }
    
    func onlyForCompanyId(id: Int) -> Bool{
        return companyId == id
    }
    
    func updateCompanyIds(allCompanyIds: Array<Int>){
        if !allCompanyIds.contains(companyId){
            companyId = 0
        }
    }
    
}

protocol FilterDelegate{
    func filterChanged()
}

