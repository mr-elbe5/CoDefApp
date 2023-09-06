/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class Filter: NSObject, Codable{
    
    enum CodingKeys: String, CodingKey {
        case companyIds
        case onlyOpen
        case onlyOverdue
    }
    
    var companyIds : Array<Int>
    var onlyOpen: Bool
    var onlyOverdue: Bool
    
    var active: Bool{
        companyIds.count != AppData.shared.companies.count || onlyOpen || onlyOverdue
    }
    
    override init(){
        self.companyIds = Array<Int>()
        onlyOpen = false
        onlyOverdue = false
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        companyIds = try values.decodeIfPresent(Array<Int>.self, forKey: .companyIds) ?? Array<Int>()
        onlyOpen = try values.decodeIfPresent(Bool.self, forKey: .onlyOpen) ?? false
        onlyOverdue = try values.decodeIfPresent(Bool.self, forKey: .onlyOverdue) ?? false
    }
    
    func initFilter(){
        if companyIds.isEmpty{
            for company in AppData.shared.companies{
                companyIds.append(company.id)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(companyIds, forKey: .companyIds)
        try container.encode(onlyOpen, forKey: .onlyOpen)
        try container.encode(onlyOverdue, forKey: .onlyOverdue)
    }
    
    func forCompanyId(id: Int) -> Bool{
        return companyIds.contains(id)
    }
    
    func updateCompanyIds(allCompanyIds: Array<Int>){
        for id in companyIds{
            if !allCompanyIds.contains(id){
                companyIds.remove(obj: id)
            }
        }
    }
    
}

protocol FilterDelegate{
    func filterChanged()
}

