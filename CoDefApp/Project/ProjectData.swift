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
    
    var filteredUnits: Array<UnitData>{
        if !isFilterActive{
            return units
        }
        var list = Array<UnitData>()
        for unit in units {
            if  unit.isInFilter(filter: filter){
                list.append(unit)
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
        for unit in units{
            unit.project = self
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
    
    func synchronizeFrom(_ fromData: ProjectData, syncResult: SyncResult) {
        super.synchronizeFrom(fromData)
        companyIds = fromData.companyIds
        for unit in fromData.units{
            if let presentUnit = units.getUnitData(id: unit.id){
                presentUnit.synchronizeFrom(unit, syncResult: syncResult)
            }
            else{
                units.append(unit)
                syncResult.loadedUnits += 1
            }
            
        }
        for unit in units{
            unit.project = self
        }
    }
    
    override func setSynchronized(_ synced: Bool = true, recursive: Bool = false){
        synchronized = synced
        if recursive{
            for unit in units{
                unit.setSynchronized(true, recursive: true)
            }
        }
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
    
    func removeUnit(_ unit: UnitData){
        unit.removeAll()
        units.remove(obj: unit)
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
        for unit in units{
            if !unit.canRemoveCompany(companyId: companyId){
                return false
            }
        }
        return true
    }
    
    func removeAll(){
        for unit in units{
            unit.removeAll()
        }
        units.removeAll()
        saveData()
    }
    
    func getUsedImageNames() -> Array<String>{
        var names = Array<String>()
        for unit in units {
            names.append(contentsOf: unit.getUsedImageNames())
        }
        return names
    }

}

typealias ProjectList = ContentDataArray<ProjectData>

extension ProjectList{
    
    func getProjectData(id: Int) -> ProjectData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol ProjectDelegate{
    func projectChanged()
}

