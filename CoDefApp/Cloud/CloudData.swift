/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class CloudData: Codable{
    
    static var storeKey = "cloudData"
    
    static var shared = CloudData()
    
    static func load(){
        shared = FileController.readJsonFile(storeKey: CloudData.storeKey) ?? CloudData()
    }
    
    func save(){
        FileController.saveJSONFile(data: self, storeKey: CloudData.storeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case serverURL
        case id
        case login
        case name
        case token
    }
    
    var serverURL = ""
    var id = 0
    var login = ""
    var name = ""
    var token = ""
    
    func isLoggedIn() -> Bool{
        return id != 0 && !name.isEmpty && !token.isEmpty
    }
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        serverURL = try values.decodeIfPresent(String.self, forKey: .serverURL) ?? ""
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        login = try values.decodeIfPresent(String.self, forKey: .login) ?? ""
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        token = try values.decodeIfPresent(String.self, forKey: .token) ?? ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serverURL, forKey: .serverURL)
        try container.encode(id, forKey: .id)
        try container.encode(login, forKey: .login)
        try container.encode(name, forKey: .name)
        try container.encode(token, forKey: .token)
    }
    
    func dump(){
        print("serverURL="+serverURL)
        print("id="+String(id))
        print("name="+name)
        print("login="+login)
        print("token="+token)
    }

}

