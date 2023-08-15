/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class AppData : Codable{
    
    static var storeKey = "appData"
    
    static var shared = AppData()
    
    static func load(){
        if let data : AppData = FileController.readJsonFile(storeKey: AppData.storeKey){
            shared = data
        }
        else{
            shared = AppData()
            shared.save()
        }
        shared.updateProjectUsers()
    }
    
    func save(){
        FileController.saveJSONFile(data: self, storeKey: AppData.storeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case projects
        case companies
    }
    
    var projects = Array<ProjectData>()
    var companies = CompanyList()
    
    var usedImageNames: Array<String>{
        var names = Array<String>()
        for project in projects {
            names.append(contentsOf: project.getUsedImageNames())
        }
        return names
    }
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        companies = try values.decodeIfPresent(CompanyList.self, forKey: .companies) ?? CompanyList()
        projects = try values.decodeIfPresent(Array<ProjectData>.self, forKey: .projects) ?? Array<ProjectData>()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(projects, forKey: .projects)
        try container.encode(companies, forKey: .companies)
    }
    
    func updateProjectUsers(){
        for project in projects {
            project.updateCompanies()
        }
    }
    
    func addProject(_ project: ProjectData){
        projects.append(project)
    }
    
    func removeProject(_ project: ProjectData){
        project.removeAll()
        projects.remove(obj: project)
    }
    
    func addUser(_ user: CompanyData){
        companies.append(user)
    }
    
    func getUser(id: Int) -> CompanyData?{
        for user in companies{
            if user.id == id{
                return user
            }
        }
        return nil
    }
    
    func removeUser(_ user: CompanyData) -> Bool{
        if canRemoveUser(userId: user.id){
            companies.remove(obj: user)
            for project in projects {
                project.companyIds.remove(obj: user.id)
                project.updateCompanies()
            }
            return true
        }
        return false
    }
    
    func canRemoveUser(userId: Int) -> Bool{
        for project in projects {
            if project.companyIds.contains(userId){
                return false
            }
        }
        return true
    }
}
