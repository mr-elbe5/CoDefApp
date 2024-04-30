/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ProjectData : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case zipCode
        case city
        case street
        case weatherStation
        case units
        case companyIds
        case dailyReports
    }
    
    var zipCode = ""
    var city = ""
    var street = ""
    var weatherStation = ""
    var units = Array<UnitData>()
    var companyIds = Array<Int>()
    var dailyReports = ProjectDailyReportList()
    
    var address: String{
        get{
            "\(zipCode) \(city), \(street)"
        }
    }
    
    //runtime
    var companies = CompanyList()
    
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
        zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        weatherStation = try values.decodeIfPresent(String.self, forKey: .weatherStation) ?? ""
        units = try values.decodeIfPresent(Array<UnitData>.self, forKey: .units) ?? Array<UnitData>()
        for unit in units{
            unit.project = self
        }
        companyIds = try values.decodeIfPresent(Array<Int>.self, forKey: .companyIds) ?? Array<Int>()
        dailyReports = try values.decodeIfPresent(ProjectDailyReportList.self, forKey: .dailyReports) ?? ProjectDailyReportList()
        for dailyReport in dailyReports{
            dailyReport.project = self
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(city, forKey: .city)
        try container.encode(street, forKey: .street)
        try container.encode(weatherStation, forKey: .weatherStation)
        try container.encode(units, forKey: .units)
        try container.encode(companyIds, forKey: .companyIds)
        try container.encode(dailyReports, forKey: .dailyReports)
    }
    
    func updateCompanies(){
        companies.removeAll()
        for companyId in companyIds{
            if let company = AppData.shared.companies.first(where: { company in
                return company.id == companyId
            }){
                companies.append(company)
            }
            else{
                companyIds.remove(obj: companyId)
            }
        }
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
            AppState.shared.updateFilterCompanyIds(allCompanyIds: companyIds)
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
    
    func isInFilter() -> Bool{
        if units.isEmpty{
            return false
        }
        for unit in units {
            if unit.isInFilter(){
                return true
            }
        }
        return false
    }
    
    func updateCompanyId(from: Int, to: Int){
        for companyId in companyIds {
            if companyId == from{
                companyIds.remove(obj: companyId)
                companyIds.append(to)
                updateCompanies()
            }
        }
        for unit in units {
            unit.updateCompanyId(from: from, to: to)
        }
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
        for dailyReport in fromData.dailyReports{
            if let presentReport = dailyReports.getContentData(id: dailyReport.id){
                await presentReport.synchronizeFrom(dailyReport)
            }
            else{
                dailyReports.append(dailyReport)
                await AppState.shared.dailyReportDownloaded()
            }
            
        }
        for unit in units{
            unit.project = self
        }
    }
    
    override var uploadParams: Dictionary<String,String>{
        var dict = super.uploadParams
        var s = ""
        for id in companyIds{
            if !s.isEmpty{
                s += ","
            }
            s += String(id)
        }
        dict["companyIds"] = s
        return dict
    }
    
    func uploadToServer() async{
        if !isOnServer{
            do{
                let requestUrl = "\(AppState.shared.serverURL)/api/project/uploadProject/\(id)"
                if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: uploadParams) {
                    print("project \(id) uploaded with new id \(response.id)")
                    await AppState.shared.projectUploaded()
                    id = response.id
                    isOnServer = true
                    saveData()
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
        else{
            await uploadUnits()
        }
    }
    
    func uploadUnits() async{
        for unit in units{
            await unit.uploadToServer()
        }
    }
    
    func sendDownloaded() async {
        await AppState.shared.projectDownloaded()
        for unit in units{
            await unit.sendDownloaded()
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

