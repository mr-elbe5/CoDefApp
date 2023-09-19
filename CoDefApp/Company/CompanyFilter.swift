/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class CompanyFilter: NSObject, Codable{
    
    enum CodingKeys: String, CodingKey {
        case companyIds
    }
    
    var companyIds : Array<Int>
    
    var active: Bool{
        companyIds.count != AppData.shared.companies.count
    }
    
    override init(){
        self.companyIds = Array<Int>()
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        companyIds = try values.decodeIfPresent(Array<Int>.self, forKey: .companyIds) ?? Array<Int>()
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
        if companyIds.isEmpty{
            companyIds.append(contentsOf: allCompanyIds)
        }
    }
    
}

protocol FilterDelegate{
    func filterChanged()
}

