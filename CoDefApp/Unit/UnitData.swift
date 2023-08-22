/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class UnitData : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case plan
        case defects
    }
    
    var plan: ImageData? = nil
    var defects = Array<DefectData>()
    
    var project: ProjectData!
    
    var projectCompanies: CompanyList{
        project.companies
    }
    
    var isFilterActive: Bool{
        project?.isFilterActive ?? false
    }
    
    var filteredDefects: Array<DefectData>{
        if let project = project{
            if !project.filter.active{
                return defects
            }
            var list = Array<DefectData>()
            for issue in defects {
                if  issue.isInFilter(filter: project.filter){
                    list.append(issue)
                }
            }
            return list
        }
        return Array<DefectData>()
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        plan = try values.decodeIfPresent(ImageData.self, forKey: .plan)
        defects = try values.decodeIfPresent(Array<DefectData>.self, forKey: .defects) ?? Array<DefectData>()
        for issue in defects{
            issue.unit = self
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
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
    
    func isInFilter(filter: Filter) -> Bool{
        if defects.isEmpty{
            return true
        }
        for issue in defects {
            if issue.isInFilter(filter: filter){
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
        for issue in defects {
            names.append(contentsOf: issue.getUsedImageNames())
        }
        return names
    }
    
    func uploadImage(syncResult: SyncResult, image: ImageData, count: Int) async throws{
        let requestUrl = AppState.shared.serverURL+"/api/unit/uploadImage/" + String(id) + "?imageId=" + String(image.id)
        await image.upload(requestUrl: requestUrl, syncResult: syncResult)
    }
    
}

protocol ScopeDelegate{
    func scopeChanged()
}
