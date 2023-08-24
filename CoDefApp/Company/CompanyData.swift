/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class CompanyData: ContentData{
    
    enum CodingKeys: String, CodingKey {
        case email
        case street
        case zipCode
        case city
        case phone
    }
    
    var street = ""
    var zipCode = ""
    var city = ""
    var email = ""
    var phone = ""
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        street = try values.decodeIfPresent(String.self, forKey: .street) ?? ""
        zipCode = try values.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? ""
        email = try values.decodeIfPresent(String.self, forKey: .email) ?? ""
        phone = try values.decodeIfPresent(String.self, forKey: .phone) ?? ""
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(street, forKey: .street)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(city, forKey: .city)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
    }
    
    func synchronizeFrom(_ fromData: CompanyData){
        super.synchronizeFrom(fromData)
        street = fromData.street
        zipCode = fromData.zipCode
        city = fromData.city
        email = fromData.email
        phone = fromData.phone
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["street"] = street
        dict["zipCode"] = zipCode
        dict["city"] = city
        dict["email"] = email
        dict["phone"] = phone
        return dict
    }
 
}

typealias CompanyList = ContentDataArray<CompanyData>

extension CompanyList{
    
    func getCompanyData(id: Int) -> CompanyData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol CompanyDelegate{
    func companyChanged()
}

protocol SelectCompaniesDelegate{
    func companiesSelected()
}

