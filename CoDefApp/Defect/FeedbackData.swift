/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class FeedbackData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case comment
        case status
        case previousAssignedUserId
        case assignedUserId
        case dueDate
        case images
    }
    
    var comment = ""
    var status = IssueStatus.open
    var previousAssignedUserId: UUID = .NIL
    var assignedUserId: UUID = .NIL
    var dueDate = Date()
    
    var images = Array<ImageFile>()
    
    var issue: IssueData? = nil
    
    var project: ProjectData?{
        issue?.project
    }
    
    var projectUsers: UserList{
        project?.users ?? UserList()
    }
    
    var creator: UserData?{
        return projectUsers.user(withId: creatorId)
    }
    
    var previousAssignedUserCloudId: Int{
        AppData.shared.users.cloudId(ofUserWithId: previousAssignedUserId)
    }
    
    var previousAssignedUser: UserData?{
        projectUsers.user(withId: previousAssignedUserId)
    }
    
    var previousAssignedUserName : String{
        projectUsers.name(ofUserWithId: previousAssignedUserId)
    }
    
    var assignedUser: UserData?{
        return projectUsers.user(withId: assignedUserId)
    }
    
    var assignedUserName : String{
        projectUsers.name(ofUserWithId: assignedUserId)
    }
    
    init(issue: IssueData){
        super.init()
        self.issue = issue
        status = issue.status
        previousAssignedUserId = issue.assignedUserId
        assignedUserId = previousAssignedUserId
        issue.project?.updateUsers()
        dueDate = issue.dueDate
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comment = try values.decodeIfPresent(String.self, forKey: .comment) ?? ""
        if let s = try values.decodeIfPresent(String.self, forKey: .status){
            status = IssueStatus(rawValue: s) ?? IssueStatus.open
        }
        else{
            status = IssueStatus.open
        }
        previousAssignedUserId = try values.decodeIfPresent(UUID.self, forKey: .previousAssignedUserId) ?? .NIL
        assignedUserId = try values.decodeIfPresent(UUID.self, forKey: .assignedUserId) ?? .NIL
        dueDate = try values.decodeIfPresent(Date.self, forKey: .dueDate) ?? Date.now
        images = try values.decodeIfPresent(Array<ImageFile>.self, forKey: .images) ?? Array<ImageFile>()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(comment, forKey: .comment)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(previousAssignedUserId, forKey: .previousAssignedUserId)
        try container.encode(assignedUserId, forKey: .assignedUserId)
        try container.encode(dueDate, forKey: .dueDate)
        try container.encode(images, forKey: .images)
    }
    
    func getUploadParams() -> Dictionary<String,String>{
        var dict = Dictionary<String,String>()
        dict["uuid"]=uuid.uuidString
        dict["creatorId"]=creatorId.uuidString
        dict["comment"]=String(comment)
        dict["status"]=status.rawValue
        dict["previousAssignedId"]=previousAssignedUserId.uuidString
        dict["assignedId"]=assignedUserId.uuidString
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
    
}

protocol FeedbackDelegate{
    func feedbackChanged()
}

