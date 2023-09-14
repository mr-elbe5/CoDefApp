/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class UnitData : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case approveDate
        case plan
        case defects
    }
    
    var approveDate : Date? = nil
    var plan: ImageData? = nil
    var defects = Array<DefectData>()
    
    var project: ProjectData!
    
    var projectCompanies: CompanyList{
        project.companies
    }
    
    var filteredDefects: Array<DefectData>{
        if !AppState.shared.filter.active{
            return defects
        }
        var list = Array<DefectData>()
        for defect in defects {
            if  defect.isInFilter(){
                list.append(defect)
            }
        }
        return list
    }
    
    init(project: ProjectData){
        self.project = project
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        approveDate = try values.decodeIfPresent(Date.self, forKey: .approveDate)
        plan = try values.decodeIfPresent(ImageData.self, forKey: .plan)
        defects = try values.decodeIfPresent(Array<DefectData>.self, forKey: .defects) ?? Array<DefectData>()
        for defect in defects{
            defect.unit = self
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let approveDate = approveDate{
            try container.encode(approveDate, forKey: .approveDate)
        }
        if let plan = plan{
            try container.encode(plan, forKey: .plan)
        }
        try container.encode(defects, forKey: .defects)
    }
    
    func removeDefect(_ issue: DefectData){
        issue.removeAll()
        defects.remove(obj: issue)
    }
    
    func setPlan(image: ImageData){
        deletePlan()
        plan = image
    }
    
    func deletePlan(){
        if let plan = plan{
            plan.deleteFile()
            self.plan = nil
        }
        
    }
    
    func getPlanImage() -> UIImage?{
        if let plan = plan {
            let image = plan.getImage()
            let rect = CGRect(x: 0 , y: 0, width: image.size.width, height: image.size.height)
            if let imageRef = image.cgImage{
                if let context = imageRef.copyContext(), let arrow = UIImage(named: "redArrow")?.cgImage{
                    for defect in filteredDefects{
                        let x = rect.width * defect.position.x
                        let y = rect.height - rect.height * defect.position.y
                        context.draw(arrow, in: CGRect(x: Int(x) - arrow.width/2, y: Int(y) - arrow.height, width: arrow.width, height: arrow.height))
                    }
                    if let img = context.makeImage(){
                        return UIImage(cgImage: img)
                    }
                }
            }
        }
        return nil
    }
    
    func removeAll(){
        deletePlan()
        for issue in defects{
            issue.removeAll()
        }
        defects.removeAll()
    }
    
    func canRemoveCompany(companyId: Int) -> Bool{
        for issue in defects{
            if !issue.canRemoveCompany(companyId: companyId){
                return false
            }
        }
        return true
    }
    
    func isInFilter() -> Bool{
        if defects.isEmpty{
            return true
        }
        for defect in defects {
            if defect.isInFilter(){
                return true
            }
        }
        return false
    }
    
    func getUsedImageNames() -> Array<String>{
        var names = Array<String>()
        if let plan = plan{
            names.append(plan.fileName)
        }
        for defect in defects {
            names.append(contentsOf: defect.getUsedImageNames())
        }
        return names
    }
    
    // sync
    
    func synchronizeFrom(_ fromData: UnitData) async{
        await super.synchronizeFrom(fromData)
        approveDate = fromData.approveDate
        plan = fromData.plan
        for defect in fromData.defects{
            if let presentDefect = defects.getDefectData(id: defect.id){
                await presentDefect.synchronizeFrom(defect)
            }
            else{
                defects.append(defect)
                AppState.shared.downloadedDefects += 1
            }
            
        }
        for defect in defects{
            defect.unit = self
        }
    }
    
    override var uploadParams: Dictionary<String,String>{
        var dict = super.uploadParams
        return dict
    }
    
    func uploadNewItems() async{
        do{
            let requestUrl = "\(AppState.shared.serverURL)/api/unit/createUnit/\(id)?parentId=\(project.id)"
            if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: uploadParams) {
                print("unit \(response.id) uploaded")
                await AppState.shared.unitUploaded()
                id = response.id
                isOnServer = true
                saveData()
                await uploadNewDefectItems()
            }
            else{
                await AppState.shared.uploadError()
                throw "unit upload error"
            }
        }
        catch let(err){
            print(err)
            await AppState.shared.uploadError()
        }
    }
    
    func uploadNewDefectItems() async{
        await withTaskGroup(of: Void.self){ taskGroup in
            for defect in defects{
                if !defect.isOnServer{
                    await defect.uploadNewItems()
                }
                else{
                    await defect.uploadNewStatusChangeItems()
                }
            }
        }
    }
    
}

typealias UnitList = ContentDataArray<UnitData>

extension UnitList{
    
    func getUnitData(id: Int) -> UnitData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol UnitDelegate{
    func unitChanged()
}
