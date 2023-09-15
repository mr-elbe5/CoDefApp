/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class StatusChangeData : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case status
        case assignedId
        case dueDate
        case images
    }
    
    var status = DefectStatus.OPEN
    var assignedId: Int = 0
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
    
    var assignedCompany: CompanyData?{
        return projectCompanies.getCompanyData(id: assignedId)
    }
    
    var assignedCompanyName : String{
        assignedCompany?.name ?? ""
    }
    
    init(defect: DefectData){
        super.init()
        self.defect = defect
        status = defect.status
        defect.project.updateCompanies()
        dueDate = defect.dueDate1
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let s = try values.decodeIfPresent(String.self, forKey: .status){
            status = DefectStatus(rawValue: s) ?? DefectStatus.OPEN
        }
        else{
            status = DefectStatus.OPEN
        }
        assignedId = try values.decodeIfPresent(Int.self, forKey: .assignedId) ?? 0
        let date = try values.decodeIfPresent(String.self, forKey: .dueDate)
        dueDate = date?.ISO8601Date() ?? Date.now
        images = try values.decodeIfPresent(ImageList.self, forKey: .images) ?? ImageList()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(assignedId, forKey: .assignedId)
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
    
    func synchronizeFrom(_ fromData: StatusChangeData) async{
        await super.synchronizeFrom(fromData)
        status = fromData.status
        assignedId = fromData.assignedId
        dueDate = fromData.dueDate
        for image in fromData.images{
            if let presentImage = images.getImageData(id: image.id){
                await presentImage.synchronizeFrom(image)
            }
            else{
                images.append(image)
                await AppState.shared.imageUploaded()
            }
            
        }
    }
    
    override var uploadParams : Dictionary<String,String>{
        var dict = super.uploadParams
        dict["status"]=status.rawValue
        dict["assignedId"]=String(assignedId)
        return dict
    }
    
    func uploadToServer() async{
        if !isOnServer{
            do{
                let requestUrl = "\(AppState.shared.serverURL)/api/defectstatus/createStatusChange/\(id)?defectId=\(defect.id)"
                if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: uploadParams) {
                    print("status change \(id) uploaded with new id \(response.id)")
                    await AppState.shared.statusChangeUploaded()
                    id = response.id
                    isOnServer = true
                    saveData()
                    await uploadImages()
                }
                else{
                    await AppState.shared.uploadError()
                    throw "status change upload error"
                }
            }
            catch{
                await AppState.shared.uploadError()
            }
        }
        else{
            await uploadImages()
        }
    }
    
    func uploadImages() async{
        for image in images{
            await image.uploadToServer(contentId: id)
        }
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

