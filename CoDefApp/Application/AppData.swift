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
        FileController.saveJsonFile(data: self, storeKey: AppData.storeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case projects
        case companies
    }
    
    var projects = ProjectList()
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
        projects = try values.decodeIfPresent(ProjectList.self, forKey: .projects) ?? ProjectList()
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
    
    func getCompany(id: Int) -> CompanyData?{
        for company in companies{
            if company.id == id{
                return company
            }
        }
        return nil
    }
    
    func removeCompany(_ company: CompanyData) -> Bool{
        if canRemoveUser(userId: company.id){
            companies.remove(obj: company)
            for project in projects {
                project.companyIds.remove(obj: company.id)
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
    
    func loadServerData() async{
        let requestUrl = AppState.shared.serverURL+"/api/root/getData"
        let params = Dictionary<String,String>()
        do{
            if let appData: AppData = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                print(appData)
                for company in appData.companies{
                    if let presentCompany = companies.getCompanyData(id: company.id){
                        await presentCompany.synchronizeFrom(company)
                    }
                    else{
                        companies.append(company)
                        await AppState.shared.companyDownloaded()
                    }
                }
                companies.sortByName()
                for project in appData.projects{
                    if let presentProject = projects.getProjectData(id: project.id){
                        await presentProject.synchronizeFrom(project)
                    }
                    else{
                        projects.append(project)
                        await AppState.shared.projectDownloaded()
                    }
                    project.updateCompanies()
                }
                projects.sortByDisplayName()
                print("saving project list")
                save()
                try await self.loadAllImages()
            }
        }
        catch (let err){
            print(err)
            await AppState.shared.downloadError()
            print("error loading projects")
        }
    }
    
    func deleteAllData(){
        companies.removeAll()
        projects.removeAll()
    }
    
    func clearProjects(){
        projects.removeAll()
        //todo clear files
    }
    
    func loadAllImages() async throws{
        //print("start loading images")
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in projects{
                for location in project.units{
                    if let plan = location.plan{
                        if !plan.fileExists() {
                            taskGroup.addTask{
                                do{
                                    try await self.loadImage(image: location.plan!)
                                }
                                catch (let err){
                                    print(err)
                                    await AppState.shared.downloadError()
                                }
                            }
                        }
                    }
                    for defect in location.defects{
                        for image in defect.images{
                            taskGroup.addTask{
                                if !image.fileExists(){
                                    do{
                                        try await self.loadImage(image: image)
                                    }
                                    catch (let err){
                                        print(err)
                                        await AppState.shared.downloadError()
                                    }
                                }
                            }
                        }
                        for statusChange in defect.statusChanges{
                            for image in statusChange.images{
                                if !image.fileExists(){
                                    taskGroup.addTask{
                                        do{
                                            try await self.loadImage(image: image)
                                        }
                                        catch (let err){
                                            print(err)
                                            await AppState.shared.downloadError()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadImage(image : ImageData) async throws{
        if (image.fileExists()){
            return
        }
        //print("file needs downloading")
        let serverUrl = AppState.shared.serverURL+"/api/image/download/" + String(image.id)
        let params = [
            "scale" : "100"
        ]
        if let img = try await RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params) {
            image.saveImage(uiImage: img)
            await AppState.shared.imageDownloaded()
        }
        else{
            print("did not receive image from /api/image/download/" + String(image.id))
            await AppState.shared.downloadError()
        }
    }
    
    func countNewElements() -> Int {
        var count = 0
        for project in projects{
            if !project.isOnServer{
                print("found new project \(project.id)")
                count += 1
            }
            for unit in project.units{
                if !unit.isOnServer{
                    print("found new unit \(unit.id)")
                    count += 1
                }
                if let plan = unit.plan, !plan.isOnServer{
                    print("found new unit plan \(plan.id)")
                    count += 1
                }
                for defect in unit.defects{
                    if !defect.isOnServer{
                        print("found new defect \(defect.id)")
                        count += 1
                    }
                    for image in defect.images{
                        if !image.isOnServer{
                            print("found new defect image \(image.id)")
                            count += 1
                        }
                    }
                    for statusChange in defect.statusChanges{
                        if !statusChange.isOnServer{
                            print("found new status change \(statusChange.id)")
                            count += 1
                        }
                        for image in statusChange.images{
                            if !image.isOnServer{
                                print("found new status change image \(image.id)")
                                count += 1
                            }
                        }
                    }
                }
            }
        }
        return count
    }
    
    func uploadToServer() async{
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in AppData.shared.projects{
                if !project.isOnServer{
                    taskGroup.addTask{
                        await project.uploadToServer()
                    }
                }
                else{
                    await project.uploadUnits()
                }
            }
        }
        AppData.shared.save()
    }
    
}
