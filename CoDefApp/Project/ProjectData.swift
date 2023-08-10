/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ProjectData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case scopes
        case userIds
        case filter
    }
    
    var name = ""
    var description = ""
    var scopes = Array<ScopeData>()
    var userIds = Array<UUID>()
    var filter = Filter()
    
    //runtime
    var users = UserList()
    
    var isFilterActive: Bool{
        filter.active
    }
    
    var filteredScopes: Array<ScopeData>{
        if !isFilterActive{
            return scopes
        }
        var list = Array<ScopeData>()
        for scope in scopes {
            if  scope.isInFilter(filter: filter){
                list.append(scope)
            }
        }
        return list
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        scopes = try values.decodeIfPresent(Array<ScopeData>.self, forKey: .scopes) ?? Array<ScopeData>()
        for scope in scopes{
            scope.project = self
        }
        userIds = try values.decodeIfPresent(Array<UUID>.self, forKey: .userIds) ?? Array<UUID>()
        filter = try values.decodeIfPresent(Filter.self, forKey: .filter) ?? Filter()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(scopes, forKey: .scopes)
        try container.encode(userIds, forKey: .userIds)
        try container.encode(filter, forKey: .filter)
    }
    
    override func asDictionary() -> Dictionary<String,String>{
        var dict = super.asDictionary()
        dict["name"]=name
        dict["description"]=description
        return dict
    }
    
    func updateUsers(){
        users.removeAll()
        for user in AppData.shared.users{
            if userIds.contains(user.uuid){
                users.append(user)
            }
        }
        saveData()
        filter.updateUserIds(allUserIds: userIds)
    }
    
    func removeScope(_ scope: ScopeData){
        scope.removeAll()
        scopes.remove(obj: scope)
        updateUsers()
    }
    
    func addUserId(_ userId: UUID){
        if !userIds.contains(userId){
            userIds.append(userId)
            updateUsers()
        }
        saveData()
    }
    
    func removeUserId(_ userId: UUID) -> Bool{
        if canRemoveUser(userId: userId){
            userIds.remove(obj: userId)
            updateUsers()
            filter.updateUserIds(allUserIds: userIds)
            saveData()
            return true
        }
        return false
    }
    
    func canRemoveUser(userId: UUID) -> Bool{
        for scope in scopes{
            if !scope.canRemoveUser(userId: userId){
                return false
            }
        }
        return true
    }
    
    func removeAll(){
        for scope in scopes{
            scope.removeAll()
        }
        scopes.removeAll()
        saveData()
    }
    
    func getUsedImageNames() -> Array<String>{
        var names = Array<String>()
        for scope in scopes {
            names.append(contentsOf: scope.getUsedImageNames())
        }
        return names
    }

}

protocol ProjectDelegate{
    func projectChanged()
}

