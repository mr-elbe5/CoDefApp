/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class AppData : Codable{
    
    static var storeKey = "appData"
    
    static var shared = AppData()
    
    static func load(){
        if let data : AppData = FileController.readJsonFile(storeKey: AppData.storeKey){
            shared = data
        }
        else{
            shared = AppData()
            shared.save()
        }
        shared.updateProjectUsers()
    }
    
    func save(){
        FileController.saveJSONFile(data: self, storeKey: AppData.storeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case projects
        case users
    }
    
    var projects = Array<ProjectData>()
    var users = UserList()
    
    var usedImageNames: Array<String>{
        var names = Array<String>()
        for project in projects {
            names.append(contentsOf: project.getUsedImageNames())
        }
        return names
    }
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        users = try values.decodeIfPresent(UserList.self, forKey: .users) ?? UserList()
        projects = try values.decodeIfPresent(Array<ProjectData>.self, forKey: .projects) ?? Array<ProjectData>()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(projects, forKey: .projects)
        try container.encode(users, forKey: .users)
    }
    
    func updateProjectUsers(){
        for project in projects {
            project.updateUsers()
        }
    }
    
    func addProject(_ project: ProjectData){
        projects.append(project)
    }
    
    func removeProject(_ project: ProjectData){
        project.removeAll()
        projects.remove(obj: project)
    }
    
    func addUser(_ user: UserData){
        users.append(user)
    }
    
    func getUser(uuid: UUID) -> UserData?{
        for user in users{
            if user.uuid == uuid{
                return user
            }
        }
        return nil
    }
    
    func removeUser(_ user: UserData) -> Bool{
        if canRemoveUser(userId: user.uuid){
            users.remove(obj: user)
            for project in projects {
                project.userIds.remove(obj: user.uuid)
                project.updateUsers()
            }
            return true
        }
        return false
    }
    
    func canRemoveUser(userId: UUID) -> Bool{
        for project in projects {
            if project.userIds.contains(userId){
                return false
            }
        }
        return true
    }
}
