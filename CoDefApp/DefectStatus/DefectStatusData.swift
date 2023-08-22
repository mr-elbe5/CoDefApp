/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class DefectStatusData : ContentData{
    
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
    
    var images = Array<ImageData>()
    
    var defect: DefectData!
    
    var project: ProjectData{
        defect.project
    }
    
    var projectCompanies: CompanyList{
        project.companies
    }
    
    var creator: CompanyData?{
        return projectCompanies.company(withId: creatorId)
    }
    
    var previousAssignedCompany: CompanyData?{
        projectCompanies.company(withId: previousAssignedCompanyId)
    }
    
    var previousAssignedCompanyName : String{
        previousAssignedCompany?.name ?? ""
    }
    
    var assignedCompany: CompanyData?{
        return projectCompanies.company(withId: assignedCompanyId)
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
        dueDate = try values.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date.now
        images = try values.decodeIfPresent(Array<ImageData>.self, forKey: .images) ?? Array<ImageData>()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(previousAssignedCompanyId, forKey: .previousAssignedCompanyId)
        try container.encode(assignedCompanyId, forKey: .assignedCompanyId)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(images, forKey: .images)
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["status"]=status.rawValue
        dict["previousAssignedCompanyId"]=String(previousAssignedCompanyId)
        dict["assignedCompanyId"]=String(assignedCompanyId)
        return dict
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
    
    func upload(syncResult: SyncResult) async{
        do{
            let requestUrl = AppState.shared.serverURL+"/api/defectstatus/upload/" + String(defect.id)
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
        let requestUrl = AppState.shared.serverURL+"/api/defectstatus/uploadImage/" + String(serverId) + "?imageId=" + String(image.id)
        await image.upload(requestUrl: requestUrl, syncResult: syncResult)
    }
    
}

protocol ProcessingStatusChangeDelegate{
    func statusChanged()
}

