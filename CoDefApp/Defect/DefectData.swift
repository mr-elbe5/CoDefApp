/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class DefectData : ContentData{
    
    public static let planCropSize = CGSize(width: 400, height: 400)
    
    public static let storeDisplayIdName = "nextDisplayId.txt"
    public static let storeDisplayIdURL = FileController.privateURL.appendingPathComponent(storeDisplayIdName)
    
    private static var nextDisplayId: Int = 0
    
    static func loadNextDisplayId(){
        if let str = FileController.readTextFile(url: storeDisplayIdURL), let id = Int(str){
            nextDisplayId = id
        }
        else{
            nextDisplayId = 0
            saveNextDisplayId()
        }
    }
    
    private static func saveNextDisplayId(){
        FileController.saveFile(text: String(nextDisplayId), url: storeDisplayIdURL)
    }
    
    static public func getNextDisplayId() -> Int{
        nextDisplayId = nextDisplayId + 1
        saveNextDisplayId()
        return nextDisplayId
    }
    
    enum CodingKeys: String, CodingKey {
        case displayId
        case status
        case projectPhase
        case assignedCompanyId
        case notified
        case dueDate1
        case dueDate2
        case positionX
        case positionY
        case positionComment
        case images
        case statusChanges
    }
    
    var displayId = 0
    var status = DefectStatus.open
    var projectPhase = ProjectPhase.PREAPPROVAL
    var assignedCompanyId: Int = 0
    var notified = false
    var dueDate1 = Date()
    var dueDate2: Date? = nil
    var position: CGPoint = .zero
    var positionComment = ""
    
    var images = ImageList()
    
    var statusChanges = StatusChangeList()
    
    var planImage: UIImage? = nil
    
    var unit: UnitData!
    
    var hasValidPosition : Bool{
        position != .zero
    }
    
    var assignedCompany : CompanyData?{
        statusChanges.last?.assignedCompany
    }
    
    var assignedCompanyName : String{
        assignedCompany?.name ?? ""
    }
    
    var isOpen: Bool{
        status == .open
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
    
    override init(){
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
        displayId = try values.decodeIfPresent(Int.self, forKey: .displayId) ?? 0
        if let s = try values.decodeIfPresent(String.self, forKey: .status){
            status = DefectStatus(rawValue: s) ?? DefectStatus.open
        }
        else{
            status = DefectStatus.open
        }
        if let s = try values.decodeIfPresent(String.self, forKey: .projectPhase){
            projectPhase = ProjectPhase(rawValue: s) ?? ProjectPhase.PREAPPROVAL
        }
        else{
            projectPhase = ProjectPhase.PREAPPROVAL
        }
        assignedCompanyId = try values.decodeIfPresent(Int.self, forKey: .assignedCompanyId) ?? 0
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
        try container.encode(displayId, forKey: .displayId)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(projectPhase.rawValue, forKey: .projectPhase)
        try container.encode(assignedCompanyId, forKey: .assignedCompanyId)
        try container.encode(notified, forKey: .notified)
        try container.encode(dueDate1.isoString(), forKey: .dueDate1)
        try container.encode(dueDate2?.isoString() ?? "", forKey: .dueDate2)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(positionComment, forKey: .positionComment)
        try container.encode(images, forKey: .images)
        try container.encode(statusChanges, forKey: .statusChanges)
    }
    
    func assertDisplayId(){
        if displayId == 0{
            displayId = DefectData.getNextDisplayId()
        }
    }
    
    func removeStatusChange(_ stausChange: StatusChangeData){
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
        if assignedCompanyId == companyId{
            return false
        }
        for statusChange in statusChanges{
            if statusChange.assignedCompanyId == companyId{
                return false
            }
        }
        return true
    }
    
    func isInFilter() -> Bool{
        if AppState.shared.filter.companyIds.contains(assignedCompanyId){
            return false
        }
        return true
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
    
    // sync
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["displayId"]=String(displayId)
        dict["status"]=status.rawValue
        dict["projectPhase"]=projectPhase.rawValue
        dict["dueDate1"]=dueDate1.isoString()
        dict["positionX"]=String(Double(position.x))
        dict["positionY"]=String(Double(position.y))
        dict["positionComment"]=positionComment
        return dict
    }
    
    func synchronizeFrom(_ fromData: DefectData, syncResult: SyncResult) {
        super.synchronizeFrom(fromData, syncResult: syncResult)
        displayId = fromData.displayId
        status = fromData.status
        projectPhase = fromData.projectPhase
        assignedCompanyId = fromData.assignedCompanyId
        notified = fromData.notified
        dueDate1 = fromData.dueDate1
        position.x = fromData.position.x
        position.y = fromData.position.y
        positionComment = fromData.positionComment
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
        for statusChange in fromData.statusChanges{
            if let presentStatusChange = statusChanges.getStatusChangeData(id: statusChange.id){
                presentStatusChange.synchronizeFrom(statusChange, syncResult: syncResult)
            }
            else{
                statusChanges.append(statusChange)
                syncResult.loadedStatusChanges += 1
                statusChange.setSynchronized(true, recursive: true)
            }
            
        }
        for statusChange in statusChanges{
            statusChange.defect = self
        }
    }
    
    override func setSynchronized(_ synced: Bool = true, recursive: Bool = false){
        synchronized = synced
        if recursive{
            for image in images{
                image.setSynchronized(synced)
            }
            for statusChange in statusChanges{
                statusChange.setSynchronized(true, recursive: true)
            }
        }
    }
    
    func upload(syncResult: SyncResult) async{
        do{
            let requestUrl = AppState.shared.serverURL+"/api/defect/uploadDefect/" + String(id)
            let params = uploadParams()
            if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                print("defect \(response.id) uploaded")
                await MainActor.run{
                    syncResult.defectUploaded()
                }
                id = response.id
                displayId = response.id
                synchronized = true
                await withTaskGroup(of: Void.self){ taskGroup in
                    for image in images{
                        if !image.synchronized{
                            taskGroup.addTask {
                                await image.upload(contentId: self.id, syncResult: syncResult)
                            }
                        }
                    }
                    await uploadStatusChanges(syncResult: syncResult)
                }
            }
            else{
                await MainActor.run{
                    syncResult.uploadError()
                }
                throw "defect upload error"
            }
        }
        catch let(err){
            print(err)
            await MainActor.run{
                syncResult.uploadError()
            }
        }
    }
    
    func uploadStatusChanges(syncResult: SyncResult) async{
        await withTaskGroup(of: Void.self){ taskGroup in
            for statusChange in statusChanges{
                if !statusChange.synchronized{
                    await statusChange.upload(syncResult: syncResult)
                }
                else{
                    await withTaskGroup(of: Void.self){ taskGroup in
                        for image in statusChange.images{
                            if !image.synchronized{
                                taskGroup.addTask {
                                    await image.upload(contentId: statusChange.id, syncResult: syncResult)
                                }
                            }
                        }
                    }
                }
            }
        }
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
