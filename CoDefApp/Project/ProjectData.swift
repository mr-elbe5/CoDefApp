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
    }
    
    var units = Array<UnitData>()
    var companyIds = Array<Int>()
    
    //runtime
    var companies = CompanyList()
    
    var filteredUnits: Array<UnitData>{
        if !AppState.shared.filter.active{
            return units
        }
        var list = Array<UnitData>()
        for unit in units {
            if  !unit.filteredDefects.isEmpty{
                list.append(unit)
            }
        }
        return list
    }
    
    var companiesText: String{
        var s = "";
        for company in companies{
            if !s.isEmpty{
                s += ", "
            }
            s += company.name
        }
        return s
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
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(units, forKey: .units)
        try container.encode(companyIds, forKey: .companyIds)
    }
    
    func updateCompanies(){
        companies.removeAll()
        for company in AppData.shared.companies{
            if companyIds.contains(company.id){
                companies.append(company)
            }
        }
        saveData()
        AppState.shared.filter.updateCompanyIds(allCompanyIds: companyIds)
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
            AppState.shared.filter.updateCompanyIds(allCompanyIds: companyIds)
            saveData()
            AppState.shared.save()
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
    
    // sync
    
    func synchronizeFrom(_ fromData: ProjectData) async{
        await super.synchronizeFrom(fromData)
        companyIds = fromData.companyIds
        updateCompanies()
        for unit in fromData.units{
            if let presentUnit = units.getUnitData(id: unit.id){
                await presentUnit.synchronizeFrom(unit)
            }
            else{
                units.append(unit)
                await AppState.shared.unitDownloaded()
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
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        //todo
        dict["companyIds"] = ""
        return dict
    }
    
    func upload() async{
        do{
            let requestUrl = AppState.shared.serverURL+"/api/project/uploadProject/" + String(id)
            let params = uploadParams()
            if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                print("project \(response.id) uploaded")
                await AppState.shared.projectUploaded()
                id = response.id
                synchronized = true
                await uploadUnits()
            }
            else{
                await AppState.shared.uploadError()
                throw "project upload error"
            }
        }
        catch let(err){
            print(err)
            await AppState.shared.uploadError()
        }
    }
    
    func uploadUnits() async{
        await withTaskGroup(of: Void.self){ taskGroup in
            for unit in units{
                if !unit.synchronized{
                    await unit.upload()
                }
                else{
                    await unit.uploadDefects()
                }
            }
        }
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

