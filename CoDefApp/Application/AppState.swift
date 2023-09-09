/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class AppState : Codable{
    
    static var storeKey = "appState"
    
    static var shared = AppState()
    
    static func load(){
        if let data : AppState = FileController.readJsonFile(storeKey: AppState.storeKey){
            shared = data
        }
        else{
            shared = AppState()
        }
        shared.save()
    }
    
    func save(){
        FileController.saveJsonFile(data: self, storeKey: AppState.storeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case lastId
        case currentUser
        case standalone
        case useDateTime
        case useNotified
        case serverURL
        case filter
    }
    
    var lastId = 1000
    var currentUser = UserData.anonymousUser
    var standalone = true
    var useDateTime = true
    var useNotified = true
    var serverURL = ""
    var filter = CompanyFilter()
    
    var nextId: Int{
        lastId += 1
        save()
        return lastId
    }
    
    func isLoggedIn() -> Bool{
        return currentUser.isLoggedIn
    }
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastId = try values.decodeIfPresent(Int.self, forKey: .lastId) ?? 1000
        currentUser = try values.decodeIfPresent(UserData.self, forKey: .currentUser) ?? UserData.anonymousUser
        standalone = try values.decodeIfPresent(Bool.self, forKey: .standalone) ?? true
        useDateTime = try values.decodeIfPresent(Bool.self, forKey: .useDateTime) ?? true
        useNotified = try values.decodeIfPresent(Bool.self, forKey: .useNotified) ?? true
        serverURL = try values.decodeIfPresent(String.self, forKey: .serverURL) ?? ""
        filter = try values.decodeIfPresent(CompanyFilter.self, forKey: .filter) ?? CompanyFilter()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastId, forKey: .lastId)
        try container.encode(currentUser, forKey: .currentUser)
        try container.encode(standalone, forKey: .standalone)
        try container.encode(useDateTime, forKey: .useDateTime)
        try container.encode(useNotified, forKey: .useNotified)
        try container.encode(serverURL, forKey: .serverURL)
        try container.encode(filter, forKey: .filter)
    }
    
}
