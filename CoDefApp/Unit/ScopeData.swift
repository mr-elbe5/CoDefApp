/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ScopeData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case plan
        case issues
    }
    
    var name = ""
    var description = ""
    var plan: ImageFile? = nil
    var issues = Array<IssueData>()
    
    var project: ProjectData? = nil
    
    var projectUsers: UserList{
        project?.users ?? UserList()
    }
    
    var isFilterActive: Bool{
        project?.isFilterActive ?? false
    }
    
    var filteredIssues: Array<IssueData>{
        if let project = project{
            if !project.filter.active{
                return issues
            }
            var list = Array<IssueData>()
            for issue in issues {
                if  issue.isInFilter(filter: project.filter){
                    list.append(issue)
                }
            }
            return list
        }
        return Array<IssueData>()
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? "name"
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        plan = try values.decodeIfPresent(ImageFile.self, forKey: .plan)
        issues = try values.decodeIfPresent(Array<IssueData>.self, forKey: .issues) ?? Array<IssueData>()
        for issue in issues{
            issue.scope = self
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        if let plan = plan{
            try container.encode(plan, forKey: .plan)
        }
        try container.encode(issues, forKey: .issues)
    }
    
    override func asDictionary() -> Dictionary<String,String>{
        var dict = super.asDictionary()
        dict["name"]=name
        dict["description"]=description
        return dict
    }
    
    func removeIssue(_ issue: IssueData){
        issue.removeAll()
        issues.remove(obj: issue)
    }
    
    func setPlan(image: ImageFile){
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
                    for issue in filteredIssues{
                        let x = rect.width * issue.position.x
                        let y = rect.height - rect.height * issue.position.y
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
        for issue in issues{
            issue.removeAll()
        }
        issues.removeAll()
    }
    
    func canRemoveUser(userId: UUID) -> Bool{
        for issue in issues{
            if !issue.canRemoveUser(userId: userId){
                return false
            }
        }
        return true
    }
    
    func isInFilter(filter: Filter) -> Bool{
        if issues.isEmpty{
            return true
        }
        for issue in issues {
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
        for issue in issues {
            names.append(contentsOf: issue.getUsedImageNames())
        }
        return names
    }
    
    override func hasUserEditRights(userId: UUID) -> Bool{
        super.hasUserEditRights(userId: userId) || (project?.hasUserEditRights(userId: userId) ?? false)
    }
    
}

protocol ScopeDelegate{
    func scopeChanged()
}
