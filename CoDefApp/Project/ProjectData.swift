/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ProjectData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case scopes
        case companyIds
        case filter
    }
    
    var name = ""
    var description = ""
    var scopes = Array<UnitData>()
    var companyIds = Array<Int>()
    var filter = Filter()
    
    //runtime
    var companies = CompanyList()
    
    var isFilterActive: Bool{
        filter.active
    }
    
    var filteredScopes: Array<UnitData>{
        if !isFilterActive{
            return scopes
        }
        var list = Array<UnitData>()
        for scope in scopes {
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
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        scopes = try values.decodeIfPresent(Array<UnitData>.self, forKey: .scopes) ?? Array<UnitData>()
        for scope in scopes{
            scope.project = self
        }
        companyIds = try values.decodeIfPresent(Array<Int>.self, forKey: .companyIds) ?? Array<Int>()
        filter = try values.decodeIfPresent(Filter.self, forKey: .filter) ?? Filter()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(scopes, forKey: .scopes)
        try container.encode(companyIds, forKey: .companyIds)
        try container.encode(filter, forKey: .filter)
    }
    
    override func asDictionary() -> Dictionary<String,String>{
        var dict = super.asDictionary()
        dict["name"]=name
        dict["description"]=description
        return dict
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
        scopes.remove(obj: scope)
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
        for scope in scopes{
            if !scope.canRemoveCompany(companyId: companyId){
                return false
            }
        }
        return true
    }
    
    func removeAll(){
        for scope in scopes{
            scope.removeAll()
        }
        scopes.removeAll()
        saveData()
    }
    
    func getUsedImageNames() -> Array<String>{
        var names = Array<String>()
        for scope in scopes {
            names.append(contentsOf: scope.getUsedImageNames())
        }
        return names
    }

}

protocol ProjectDelegate{
    func projectChanged()
}

