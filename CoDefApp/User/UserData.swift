/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class UserData: BaseData{
    
    static var anonymousUserId = UUID.NIL
    static var anonymousUser = UserData(id: anonymousUserId, name: "anonymous".localize())
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case street
        case zipCode
        case city
        case phone
        case notes
        case rights
    }
    
    var name = ""
    var street = ""
    var zipCode = ""
    var city = ""
    var email = ""
    var phone = ""
    var notes = ""
    var rights = Rights()
    
    var hasProjectEditRight: Bool{
        rights.hasProjectEditRight
    }
    
    var hasGlobalEditRight: Bool{
        rights.hasGlobalEditRight
    }
    
    var hasSystemRight: Bool{
        rights.hasSystemRight
    }
    
    override init(){
        super.init()
    }
    
    private init(id: UUID, name: String){
        super.init(uuid: id)
        self.name = name
        self.rights = Rights(projectEdit: true, globalEdit: true, system: true)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        email = try values.decodeIfPresent(String.self, forKey: .email) ?? ""
        phone = try values.decodeIfPresent(String.self, forKey: .phone) ?? ""
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
        rights = try values.decodeIfPresent(Rights.self, forKey: .rights) ?? Rights()
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(street, forKey: .street)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(city, forKey: .city)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(notes, forKey: .notes)
        try container.encode(rights, forKey: .rights)
    }
    
    override func asDictionary() -> Dictionary<String,String>{
        var dict = super.asDictionary()
        dict["name"] = name
        dict["street"] = street
        dict["zipCode"] = zipCode
        dict["city"] = city
        dict["email"] = email
        dict["phone"] = phone
        dict["notes"] = notes
        return dict
    }
 
}

protocol UserDelegate{
    func userChanged()
}

protocol SelectUsersDelegate{
    func usersSelected()
}

