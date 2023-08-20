/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class CompanyData: BaseData{
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case street
        case zipCode
        case city
        case phone
        case notes
    }
    
    var name = ""
    var street = ""
    var zipCode = ""
    var city = ""
    var email = ""
    var phone = ""
    var notes = ""
    
    override init(){
        super.init()
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
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
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

protocol CompanyDelegate{
    func companyChanged()
}

protocol SelectCompaniesDelegate{
    func companiesSelected()
}

