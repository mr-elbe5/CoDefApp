/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ProjectData : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case units
        case companyIds
        case filter
    }
    
    var units = Array<UnitData>()
    var companyIds = Array<Int>()
    var filter = Filter()
    
    //runtime
    var companies = CompanyList()
    
    var isFilterActive: Bool{
        filter.active
    }
    
    var filteredScopes: Array<UnitData>{
        if !isFilterActive{
            return units
        }
        var list = Array<UnitData>()
        for scope in units {
            if  scope.isInFilter(filter: filter){
                list.append(scope)
            }
        }
        return list
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        units = try values.decodeIfPresent(Array<UnitData>.self, forKey: .units) ?? Array<UnitData>()
        for scope in units{
            scope.project = self
        }
        companyIds = try values.decodeIfPresent(Array<Int>.self, forKey: .companyIds) ?? Array<Int>()
        filter = try values.decodeIfPresent(Filter.self, forKey: .filter) ?? Filter()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(units, forKey: .units)
        try container.encode(companyIds, forKey: .companyIds)
        try container.encode(filter, forKey: .filter)
    }
    
    func updateCompanies(){
        companies.removeAll()
        for company in AppData.shared.companies{
            if companyIds.contains(company.id){
                companies.append(company)
            }
        }
        saveData()
        filter.updateCompanyIds(allCompanyIds: companyIds)
    }
    
    func removeScope(_ scope: UnitData){
        scope.removeAll()
        units.remove(obj: scope)
        updateCompanies()
    }
    
    func addCompanyId(_ userId: Int){
        if !companyIds.contains(userId){
            companyIds.append(userId)
            updateCompanies()
        }
        saveData()
    }
    
    func removeCompanyId(_ companyId: Int) -> Bool{
        if canRemoveCompany(companyId: companyId){
            companyIds.remove(obj: companyId)
            updateCompanies()
            filter.updateCompanyIds(allCompanyIds: companyIds)
            saveData()
            return true
        }
        return false
    }
    
    func canRemoveCompany(companyId: Int) -> Bool{
        for scope in units{
            if !scope.canRemoveCompany(companyId: companyId){
                return false
            }
        }
        return true
    }
    
    func removeAll(){
        for scope in units{
            scope.removeAll()
        }
        units.removeAll()
        saveData()
    }
    
    func getUsedImageNames() -> Array<String>{
        var names = Array<String>()
        for scope in units {
            names.append(contentsOf: scope.getUsedImageNames())
        }
        return names
    }

}

protocol ProjectDelegate{
    func projectChanged()
}

