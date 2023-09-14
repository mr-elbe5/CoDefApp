/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ContentData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case name
        case displayName
        case description
    }
    
    var name = ""
    var displayName = ""
    var description = ""
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? name
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(description, forKey: .description)
    }
    
    // sync
    
    func synchronizeFrom(_ fromData: ContentData) async{
        await super.synchronizeFrom(fromData)
        name = fromData.name
        displayName = fromData.displayName
        description = fromData.description
    }
    
    override var uploadParams : Dictionary<String,String>{
        var dict = super.uploadParams
        dict["name"]=name
        dict["displayName"]=displayName
        dict["description"]=description
        return dict
    }
    
}

typealias ContentDataArray<T: ContentData> = Array<T>

extension ContentDataArray{
    
    var names: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].name)
        }
        return list
    }
    
    func getContentData(id: Int) -> ContentData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
    func getContentData(name: String) -> ContentData?{
        for data in self{
            if data.name == name {
                return data
            }
        }
        return nil
    }
    
    func getContentData(displayName: String) -> ContentData?{
        for data in self{
            if data.displayName == displayName {
                return data
            }
        }
        return nil
    }
    
    mutating func sortByName(){
        self = self.sorted {
            $0.name < $1.name
        }
    }
    
    mutating func sortByDisplayName(){
        self = self.sorted {
            $0.displayName < $1.displayName
        }
    }
    
}

