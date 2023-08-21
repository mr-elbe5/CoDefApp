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
    
    func loadProjects(syncResult: SyncResult) async{
        let requestUrl = AppState.shared.serverURL+"/api/project/getProjects"
        let params = Dictionary<String,String>()
        do{
            if let projectList: Array<ProjectData> = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                //print(projectList.projects)
                await MainActor.run{
                    syncResult.projectsLoaded = projectList.count
                    for project in projectList{
                        syncResult.unitsLoaded += project.units.count
                        for unit in project.units{
                            syncResult.defectsLoaded += unit.defects.count
                        }
                    }
                }
                try await self.loadProjectImages(data: projectList, syncResult: syncResult)
                print("saving project list")
                AppData.shared.projects = projectList
            }
        }
        catch {
            await MainActor.run{
                syncResult.downloadErrors += 1
            }
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
    
    func loadProjectImages(data: Array<ProjectData>, syncResult: SyncResult) async throws{
        //print("start loading images")
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in projects{
                for location in project.units{
                    if location.plan != nil {
                        taskGroup.addTask{
                            do{
                                try await self.loadProjectImage(image: location.plan!, syncResult: syncResult)
                            }
                            catch{
                                await MainActor.run{
                                    syncResult.downloadErrors += 1
                                }
                            }
                        }
                    }
                    for defect in location.defects{
                        for image in defect.images{
                            taskGroup.addTask{
                                do{
                                    try await self.loadProjectImage(image: image, syncResult: syncResult)
                                }
                                catch{
                                    await MainActor.run{
                                        syncResult.downloadErrors += 1
                                    }
                                }
                            }
                        }
                        for statusChange in defect.statusChanges{
                            for image in statusChange.images{
                                taskGroup.addTask{
                                    do{
                                        try await self.loadProjectImage(image: image, syncResult: syncResult)
                                    }
                                    catch{
                                        await MainActor.run{
                                            syncResult.downloadErrors += 1
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
    
    func loadProjectImage(image : ImageData, syncResult: SyncResult) async throws{
        if (image.fileExists()){
            await MainActor.run{
                syncResult.imagesPresent += 1
            }
            return
        }
        //print("file needs downloading")
        let serverUrl = AppState.shared.serverURL+"/api/image/download/" + String(image.id)
        let params = [
            "scale" : "100"
        ]
        if let img = try await RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params) {
            image.saveImage(uiImage: img)
            await MainActor.run{
                syncResult.imagesLoaded += 1
            }
        }
        else{
            await MainActor.run{
                syncResult.downloadErrors += 1
            }
        }
    }
    
    func countNewElements() -> Int {
        var count = 0
        for project in projects{
            for unit in project.units{
                for defect in unit.defects{
                    if defect.isNew{
                        print("found new defect \(defect.id)")
                        count += 1
                    }
                    for image in defect.images{
                        if image.isNew{
                            print("found new defect image \(image.id)")
                            count += 1
                        }
                    }
                    for statusChange in defect.statusChanges{
                        if statusChange .isNew{
                            print("found new status change \(statusChange.id)")
                            count += 1
                        }
                        for image in statusChange.images{
                            if image.isNew{
                                print("found new comment image \(image.id)")
                                count += 1
                            }
                        }
                    }
                }
            }
        }
        return count
    }
    
    func uploadNewItems(syncResult: SyncResult) async{
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in AppData.shared.projects{
                for location in project.units{
                    for defect in location.defects{
                        if (defect.isNew){
                            taskGroup.addTask{
                                await defect.upload(syncResult: syncResult)
                            }
                        }
                        else{
                            var count = 0
                            for image in defect.images{
                                if (image.isNew){
                                    count += 1
                                    let nextCount = count
                                    taskGroup.addTask{
                                        await defect.uploadImage(image: image, count: nextCount, syncResult: syncResult)
                                    }
                                }
                            }
                            for defectStatus in defect.statusChanges{
                                if (defectStatus.isNew){
                                    taskGroup.addTask{
                                        await defectStatus.upload(syncResult: syncResult)
                                    }
                                }
                                else{
                                    var count = 0
                                    for image in defect.images{
                                        if (image.isNew){
                                            count += 1
                                            let nextCount = count
                                            taskGroup.addTask{
                                                await defectStatus.uploadImage(image: image, count: nextCount, syncResult: syncResult)
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
        AppData.shared.save()
    }
    
}
