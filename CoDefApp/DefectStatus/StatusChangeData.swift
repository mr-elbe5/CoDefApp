/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class StatusChangeData : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case status
        case previousAssignedCompanyId
        case assignedCompanyId
        case dueDate
        case images
    }
    
    var status = DefectStatus.open
    var previousAssignedCompanyId: Int = 0
    var assignedCompanyId: Int = 0
    var dueDate = Date()
    
    var images = ImageList()
    
    var defect: DefectData!
    
    var project: ProjectData{
        defect.project
    }
    
    var projectCompanies: CompanyList{
        project.companies
    }
    
    var creator: CompanyData?{
        return projectCompanies.getCompanyData(id: creatorId)
    }
    
    var previousAssignedCompany: CompanyData?{
        projectCompanies.getCompanyData(id: previousAssignedCompanyId)
    }
    
    var previousAssignedCompanyName : String{
        previousAssignedCompany?.name ?? ""
    }
    
    var assignedCompany: CompanyData?{
        return projectCompanies.getCompanyData(id: assignedCompanyId)
    }
    
    var assignedCompanyName : String{
        assignedCompany?.name ?? ""
    }
    
    init(defect: DefectData){
        super.init()
        self.defect = defect
        status = defect.status
        previousAssignedCompanyId = defect.assignedCompanyId
        assignedCompanyId = previousAssignedCompanyId
        defect.project.updateCompanies()
        dueDate = defect.dueDate
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let s = try values.decodeIfPresent(String.self, forKey: .status){
            status = DefectStatus(rawValue: s) ?? DefectStatus.open
        }
        else{
            status = DefectStatus.open
        }
        previousAssignedCompanyId = try values.decodeIfPresent(Int.self, forKey: .previousAssignedCompanyId) ?? 0
        assignedCompanyId = try values.decodeIfPresent(Int.self, forKey: .assignedCompanyId) ?? 0
        let date = try values.decodeIfPresent(String.self, forKey: .dueDate)
        dueDate = date?.ISO8601Date() ?? Date.now
        images = try values.decodeIfPresent(ImageList.self, forKey: .images) ?? ImageList()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(previousAssignedCompanyId, forKey: .previousAssignedCompanyId)
        try container.encode(assignedCompanyId, forKey: .assignedCompanyId)
        try container.encode(dueDate.isoString(), forKey: .dueDate)
        try container.encode(images, forKey: .images)
    }
    
    func removeAll(){
        for img in images{
            img.deleteFile()
        }
        images.removeAll()
    }
    
    func getUsedImageNames()  -> Array<String>{
        var names = Array<String>()
        for image in images{
            names.append(image.fileName)
        }
        return names
    }
    
    // sync
    
    func synchronizeFrom(_ fromData: StatusChangeData, syncResult: SyncResult) {
        super.synchronizeFrom(fromData, syncResult: syncResult)
        status = fromData.status
        previousAssignedCompanyId = fromData.previousAssignedCompanyId
        assignedCompanyId = fromData.assignedCompanyId
        dueDate = fromData.dueDate
        for image in fromData.images{
            if let presentImage = images.getImageData(id: image.id){
                presentImage.synchronizeFrom(image, syncResult: syncResult)
            }
            else{
                images.append(image)
                syncResult.loadedImages += 1
                image.setSynchronized()
            }
            
        }
    }
    
    override func setSynchronized(_ synced: Bool = true, recursive: Bool = false){
        synchronized = synced
        if recursive{
            for image in images{
                image.setSynchronized(synced)
            }
        }
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["status"]=status.rawValue
        dict["previousAssignedCompanyId"]=String(previousAssignedCompanyId)
        dict["assignedCompanyId"]=String(assignedCompanyId)
        return dict
    }
    
    func upload(syncResult: SyncResult) async{
        do{
            let requestUrl = AppState.shared.serverURL+"/api/statuschange/uploadStatusChange/" + String(defect.id)
            let params = uploadParams()
            if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                print("status change \(response.id) uploaded")
                await MainActor.run{
                    syncResult.statusChangeUploaded()
                }
                id = response.id
                synchronized = true
                for image in images{
                    if !image.synchronized{
                        await uploadImage(image: image, syncResult: syncResult)
                    }
                }
            }
            else{
                await MainActor.run{
                    syncResult.uploadError()
                }
                throw "status change upload error"
            }
        }
        catch{
            await MainActor.run{
                syncResult.uploadError()
            }
        }
    }
    
    func uploadImage(image: ImageData, syncResult: SyncResult) async{
        let requestUrl = AppState.shared.serverURL+"/api/statuschange/uploadStatusChangeImage/" + String(id)
        await image.upload(requestUrl: requestUrl, syncResult: syncResult)
    }
    
}

typealias StatusChangeList = ContentDataArray<StatusChangeData>

extension StatusChangeList{
    
    func getStatusChangeData(id: Int) -> StatusChangeData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol StatusChangeDelegate{
    func statusChanged()
}

