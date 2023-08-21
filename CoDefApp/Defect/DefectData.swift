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
        case assignedCompanyId
        case notified
        case dueDate
        case positionX
        case positionY
        case positionComment
        case images
        case statusChanges
    }
    
    var displayId = 0
    var status = DefectStatus.open
    var assignedCompanyId: Int = 0
    var notified = false
    var dueDate = Date()
    var position: CGPoint = .zero
    var positionComment = ""
    
    var images = Array<ImageData>()
    
    var statusChanges = Array<DefectStatusData>()
    
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
        dueDate < Date()
    }
    
    var project: ProjectData{
        unit.project
    }
    
    var projectUsers: CompanyList{
        project.companies
    }
    
    override init(){
        super.init()
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
        assignedCompanyId = try values.decodeIfPresent(Int.self, forKey: .assignedCompanyId) ?? 0
        notified = try values.decodeIfPresent(Bool.self, forKey: .notified) ?? false
        dueDate = try values.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date.now
        position.x = try values.decodeIfPresent(Double.self, forKey: .positionX) ?? 0.0
        position.y = try values.decodeIfPresent(Double.self, forKey: .positionY) ?? 0.0
        positionComment = try values.decodeIfPresent(String.self, forKey: .positionComment) ?? ""
        images = try values.decodeIfPresent(Array<ImageData>.self, forKey: .images) ?? Array<ImageData>()
        statusChanges = try values.decodeIfPresent(Array<DefectStatusData>.self, forKey: .statusChanges) ?? Array<DefectStatusData>()
        for statusChange in statusChanges{
            statusChange.defect = self
        }
        
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayId, forKey: .displayId)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(assignedCompanyId, forKey: .assignedCompanyId)
        try container.encode(notified, forKey: .notified)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(position.x, forKey: .positionX)
        try container.encode(position.y, forKey: .positionY)
        try container.encode(positionComment, forKey: .positionComment)
        try container.encode(images, forKey: .images)
        try container.encode(statusChanges, forKey: .statusChanges)
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["displayId"]=String(displayId)
        dict["status"]=status.rawValue
        dict["dueDate"]=dueDate.isoString()
        dict["positionX"]=String(Double(position.x))
        dict["positionY"]=String(Double(position.y))
        dict["positionComment"]=positionComment
        return dict
    }
    
    func assertDisplayId(){
        if displayId == 0{
            displayId = DefectData.getNextDisplayId()
        }
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
    
    func isInFilter(filter: Filter) -> Bool{
        if filter.onlyOpen && status == .done{
            return false
        }
        if filter.onlyOverdue && !isOverdue{
            return false
        }
        if filter.companyId != 0 && filter.companyId != assignedCompanyId{
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
    
    func upload(syncResult: SyncResult) async{
        do{
            let requestUrl = AppState.shared.serverURL+"/api/defect/uploadNewDefect/" + String(id)
            var params = uploadParams()
            params["creationDate"] = String(creationDate.millisecondsSince1970)
            params["dueDate"] = String(dueDate.millisecondsSince1970)
            if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                print("defect \(response.id) uploaded")
                await MainActor.run{
                    syncResult.defectsUploaded += 1
                    syncResult.itemsUploaded += 1.0
                    syncResult.updateUpload()
                }
                id = response.id
                displayId = response.id
                await withTaskGroup(of: Void.self){ taskGroup in
                    var count = 0
                    for image in images{
                        count += 1
                        await uploadImage(image: image, count: count, syncResult: syncResult)
                    }
                    for statusChange in statusChanges{
                        if (statusChange.isNew){
                            await statusChange.upload(syncResult: syncResult)
                        }
                    }
                }
            }
            else{
                await MainActor.run{
                    syncResult.uploadErrors += 1
                }
                throw "defect upload error"
            }
        }
        catch{
            await MainActor.run{
                syncResult.uploadErrors += 1
            }
        }
    }
    
    func uploadImage(image: ImageData, count: Int, syncResult: SyncResult) async{
        let requestUrl = AppState.shared.serverURL+"/api/defect/uploadImage/" + String(id) + "?imageId=" + String(image.id)
        let newFileName = "img-\(id)-\(count).jpg"
        await uploadImage(requestUrl: requestUrl, image: image, fileName: newFileName, syncResult: syncResult)
    }
    
}

protocol DefectDelegate{
    func defectChanged()
}

protocol DefectPositionDelegate{
    func positionChanged(position: CGPoint)
}
