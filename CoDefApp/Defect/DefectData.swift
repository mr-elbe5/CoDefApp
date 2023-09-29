/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class DefectData : ContentData{
    
    public static let planCropSize = CGSize(width: 400, height: 400)
    
    enum CodingKeys: String, CodingKey {
        case projectPhase
        case assignedId
        case notified
        case dueDate1
        case dueDate2
        case positionX
        case positionY
        case positionComment
        case images
        case statusChanges
    }
    
    var projectPhase = ProjectPhase.PREAPPROVAL
    var assignedId: Int = 0
    var notified = false
    var dueDate1 = Date()
    var dueDate2: Date? = nil
    var position: CGPoint = .zero
    var positionComment = ""
    
    var images = ImageList()
    
    var statusChanges = StatusChangeList()
    
    var planImage: UIImage? = nil
    
    var unit: UnitData!
    
    override var displayName: String{
        get{
            "defect".localize() + " " + String(id)
        }
        set{
        }
    }
    
    var hasValidPosition : Bool{
        position != .zero
    }
    
    var assignedCompany : CompanyData?{
        if let company = statusChanges.last?.assignedCompany{
            return company
        }
        return AppData.shared.getCompany(id: assignedId)
    }
    
    var assignedCompanyName : String{
        assignedCompany?.name ?? ""
    }
    
    var status: DefectStatus{
        if statusChanges.isEmpty{
            return .OPEN
        }
        return statusChanges.last!.status
    }
    
    var isOpen: Bool{
        status == .OPEN
    }
    
    var dueDate: Date{
        if let date = dueDate2{
            return date
        }
        return dueDate1
    }
    
    var isOverdue : Bool{
        dueDate1 < Date()
    }
    
    var project: ProjectData{
        unit.project
    }
    
    var projectUsers: CompanyList{
        project.companies
    }
    
    init(unit: UnitData){
        self.unit = unit
        super.init()
        if let approveDate = unit.approveDate{
            projectPhase = approveDate > Date() ? .PREAPPROVAL : .LIABILITY
        }
        else{
            projectPhase = .PREAPPROVAL
        }
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let s = try values.decodeIfPresent(String.self, forKey: .projectPhase){
            projectPhase = ProjectPhase(rawValue: s) ?? ProjectPhase.PREAPPROVAL
        }
        else{
            projectPhase = ProjectPhase.PREAPPROVAL
        }
        assignedId = try values.decodeIfPresent(Int.self, forKey: .assignedId) ?? 0
        notified = try values.decodeIfPresent(Bool.self, forKey: .notified) ?? false
        var date = try values.decodeIfPresent(String.self, forKey: .dueDate1)
        dueDate1 = date?.ISO8601Date() ?? Date.now
        date = try values.decodeIfPresent(String.self, forKey: .dueDate2)
        dueDate2 = date?.ISO8601Date()
        position.x = try values.decodeIfPresent(Double.self, forKey: .positionX) ?? 0.0
        position.y = try values.decodeIfPresent(Double.self, forKey: .positionY) ?? 0.0
        positionComment = try values.decodeIfPresent(String.self, forKey: .positionComment) ?? ""
        images = try values.decodeIfPresent(ImageList.self, forKey: .images) ?? ImageList()
        statusChanges = try values.decodeIfPresent(StatusChangeList.self, forKey: .statusChanges) ?? StatusChangeList()
        for statusChange in statusChanges{
            statusChange.defect = self
        }
        
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(projectPhase.rawValue, forKey: .projectPhase)
        try container.encode(assignedId, forKey: .assignedId)
        try container.encode(notified, forKey: .notified)
        try container.encode(dueDate1.isoString(), forKey: .dueDate1)
        try container.encode(dueDate2?.isoString() ?? "", forKey: .dueDate2)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(positionComment, forKey: .positionComment)
        try container.encode(images, forKey: .images)
        try container.encode(statusChanges, forKey: .statusChanges)
    }
    
    func removeStatusChange(_ stausChange: DefectStatusData){
        stausChange.removeAll()
        statusChanges.remove(obj: stausChange)
    }
    
    func removeAll(){
        for img in images{
            img.deleteFile()
        }
        images.removeAll()
        for feedback in statusChanges{
            feedback.removeAll()
        }
        statusChanges.removeAll()
    }
    
    func createPlanImage(){
        if let plan = unit?.plan {
            let image = plan.getImage()
            let origPosX = image.size.width*position.x
            let origPosY = image.size.height*position.y
            let posX = min(max(origPosX , DefectData.planCropSize.width/2), image.size.width - DefectData.planCropSize.width/2)
            let posY = min(max(origPosY, DefectData.planCropSize.height/2), image.size.height - DefectData.planCropSize.height/2)
            let dx = Int(posX - origPosX)
            let dy = Int(posY - origPosY)
            let rect = CGRect(x: posX - DefectData.planCropSize.width/2, y: posY - DefectData.planCropSize.height/2, width: DefectData.planCropSize.width, height: DefectData.planCropSize.height)
            if let cutImageRef = image.cgImage?.cropping(to:rect){
                if let context = cutImageRef.copyContext(), let arrow = UIImage(named: "redArrow")?.cgImage{
                    context.draw(arrow, in: CGRect(x: Int(rect.width/2) - arrow.width/2 + dx, y: Int(rect.height/2) - arrow.height  + dy, width: arrow.width, height: arrow.height))
                    if let img = context.makeImage(){
                        planImage = UIImage(cgImage: img)
                    }
                }
            }
        }
    }
    
    func assertPlanImage(){
        if planImage == nil && position != .zero && unit?.plan != nil{
            createPlanImage()
        }
    }
    
    func canRemoveCompany(companyId: Int) -> Bool{
        if assignedId == companyId{
            return false
        }
        for statusChange in statusChanges{
            if statusChange.assignedId == companyId{
                return false
            }
        }
        return true
    }
    
    func isInFilter() -> Bool{
        AppState.shared.filterCompanyIds.contains(assignedId)
    }
    
    func getUsedImageNames() -> Array<String>{
        var names = Array<String>()
        for image in images{
            names.append(image.fileName)
        }
        for statusChange in statusChanges {
            names.append(contentsOf: statusChange.getUsedImageNames())
        }
        return names
    }
    
    func updateCompanyId(from: Int, to: Int){
        if assignedId == from{
            assignedId = to
        }
        for statusChange in statusChanges {
            statusChange.updateCompanyId(from: from, to: to)
        }
    }
    
    // sync
    
    override var uploadParams: Dictionary<String,String>{
        var dict = super.uploadParams
        dict["projectPhase"]=projectPhase.rawValue
        dict["dueDate1"]=dueDate1.isoString()
        dict["positionX"]=String(Double(position.x))
        dict["positionY"]=String(Double(position.y))
        dict["positionComment"]=positionComment
        dict["assignedId"]=String(assignedId)
        dict["status"] = status.rawValue
        return dict
    }
    
    func synchronizeFrom(_ fromData: DefectData) async{
        await super.synchronizeFrom(fromData)
        projectPhase = fromData.projectPhase
        assignedId = fromData.assignedId
        notified = fromData.notified
        dueDate1 = fromData.dueDate1
        position.x = fromData.position.x
        position.y = fromData.position.y
        positionComment = fromData.positionComment
        for image in fromData.images{
            if let presentImage = images.getImageData(id: image.id){
                await presentImage.synchronizeFrom(image)
            }
            else{
                images.append(image)
                AppState.shared.downloadedImages += 1
            }
            
        }
        for statusChange in fromData.statusChanges{
            if let presentStatusChange = statusChanges.getStatusChangeData(id: statusChange.id){
                await presentStatusChange.synchronizeFrom(statusChange)
            }
            else{
                statusChanges.append(statusChange)
                await AppState.shared.statusChangeDownloaded()
            }
            
        }
        for statusChange in statusChanges{
            statusChange.defect = self
        }
    }
    
    func uploadToServer() async{
        if !isOnServer{
            do{
                let requestUrl = "\(AppState.shared.serverURL)/api/defect/uploadDefect/\(id)?unitId=\(unit.id)"
                if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: uploadParams) {
                    print("defect \(id) uploaded with new id \(response.id)")
                    await AppState.shared.defectUploaded()
                    id = response.id
                    isOnServer = true
                    saveData()
                    await uploadImages()
                    await uploadStateChanges()
                }
                else{
                    await AppState.shared.uploadError()
                    throw "defect upload error"
                }
            }
            catch let(err){
                print(err)
                await AppState.shared.uploadError()
            }
        }
    }
    
    func uploadImages() async{
        for image in images{
            await image.uploadToServer(contentId: id)
        }
    }
    
    func uploadStateChanges() async{
        for statusChange in statusChanges{
            await statusChange.uploadToServer()
        }
    }
    
    func sendDownloaded() async{
        await AppState.shared.defectDownloaded()
        for statusChange in statusChanges{
            await statusChange.sendDownloaded()
        }
    }
    
    func indexOf(changeData: DefectStatusData) -> Int{
        for i in 0..<statusChanges.count{
            if statusChanges[i] == changeData{
                return i
            }
        }
        return -1
    }
    
}

typealias DefectList = ContentDataArray<DefectData>

extension DefectList{
    
    func getDefectData(id: Int) -> DefectData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol DefectDelegate{
    func defectChanged()
}

protocol DefectPositionDelegate{
    func positionChanged(position: CGPoint)
}
