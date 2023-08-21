/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class UserData: Codable{
    
    static var anonymousUserId = 0
    static var anonymousUser = UserData(id: anonymousUserId, name: "anonymous".localize())
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case name
        case token
        case isEditor
        case isAdministrator
    }
    
    var id : Int
    var login: String
    var name: String
    var token: String? = nil
    var isEditor: Bool = false
    var isAdministrator: Bool = false
    
    var isLoggedIn: Bool{
        id != 0 && !name.isEmpty && token != nil
    }
    
    var hasSystemRight: Bool{
        return true
    }
    
    var hasEditRight: Bool{
        return true
    }
    
    init(id: Int, name: String){
        self.id = id
        self.name = name
        login = ""
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        login = try values.decodeIfPresent(String.self, forKey: .login) ?? ""
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        token = try values.decodeIfPresent(String.self, forKey: .token)
        isEditor = try values.decodeIfPresent(Bool.self, forKey: .isEditor) ?? false
        isAdministrator = try values.decodeIfPresent(Bool.self, forKey: .isAdministrator) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(login, forKey: .login)
        try container.encode(name, forKey: .name)
        try container.encode(token, forKey: .token)
        try container.encode(isEditor, forKey: .isEditor)
        try container.encode(isAdministrator, forKey: .isAdministrator)
    }
    
    func dump(){
        print("login data:");
        print("id: \(id)");
        print("login: \(login)");
        print("name: \(name)");
        print("token: \(token)");
        print("isEditor: \(isEditor)");
        print("isAdministartor: \(isAdministrator)");
    }
 
}


