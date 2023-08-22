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
    
    func addCompany(_ company: CompanyData){
        companies.append(company)
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
    
    func loadProjects(syncResult: SyncResult) async{
        let requestUrl = AppState.shared.serverURL+"/api/project/getProjects"
        let params = Dictionary<String,String>()
        do{
            if let projectList: Array<ProjectData> = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                //print(projectList.projects)
                await MainActor.run{
                    syncResult.loadedProjects = projectList.count
                    for project in projectList{
                        syncResult.loadedUnits += project.units.count
                        for unit in project.units{
                            syncResult.loadedDefects += unit.defects.count
                        }
                    }
                }
                syncResult.updateDownload()
                try await self.loadAllImages(data: projectList, syncResult: syncResult)
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
    
    func loadAllImages(data: Array<ProjectData>, syncResult: SyncResult) async throws{
        //print("start loading images")
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in projects{
                for location in project.units{
                    if location.plan != nil {
                        taskGroup.addTask{
                            do{
                                try await self.loadImage(image: location.plan!, syncResult: syncResult)
                            }
                            catch{
                                await MainActor.run{
                                    syncResult.downloadErrors += 1
                                    syncResult.updateDownload()
                                }
                            }
                        }
                    }
                    for defect in location.defects{
                        for image in defect.images{
                            taskGroup.addTask{
                                do{
                                    try await self.loadImage(image: image, syncResult: syncResult)
                                }
                                catch{
                                    await MainActor.run{
                                        syncResult.downloadErrors += 1
                                        syncResult.updateDownload()
                                    }
                                }
                            }
                        }
                        for statusChange in defect.statusChanges{
                            for image in statusChange.images{
                                taskGroup.addTask{
                                    do{
                                        try await self.loadImage(image: image, syncResult: syncResult)
                                    }
                                    catch{
                                        await MainActor.run{
                                            syncResult.downloadErrors += 1
                                            syncResult.updateDownload()
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
    
    func loadImage(image : ImageData, syncResult: SyncResult) async throws{
        if (image.fileExists()){
            await MainActor.run{
                syncResult.presentImages += 1
                syncResult.updateDownload()
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
                syncResult.loadedImages += 1
                syncResult.updateDownload()
            }
        }
        else{
            await MainActor.run{
                syncResult.downloadErrors += 1
                syncResult.updateDownload()
            }
        }
    }
    
    func countUnsynchronizedElements() -> Int {
        var count = 0
        for project in projects{
            if !project.synchronized{
                print("found unsynchronized project \(project.id)")
                count += 1
            }
            for unit in project.units{
                if !unit.synchronized{
                    print("found unsynchronized unit \(unit.id)")
                    count += 1
                }
                if let plan = unit.plan, !plan.synchronized{
                    print("found unsynchronized unit plan \(plan.id)")
                    count += 1
                }
                for defect in unit.defects{
                    if !defect.synchronized{
                        print("found unsynchronized defect \(defect.id)")
                        count += 1
                    }
                    for image in defect.images{
                        if !image.synchronized{
                            print("found unsynchronized defect image \(image.id)")
                            count += 1
                        }
                    }
                    for statusChange in defect.statusChanges{
                        if !statusChange.synchronized{
                            print("found unsynchronized status change \(statusChange.id)")
                            count += 1
                        }
                        for image in statusChange.images{
                            if !image.synchronized{
                                print("found unsynchronized comment image \(image.id)")
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
