/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ContentData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case description
    }
    
    private var name = ""
    
    var displayName: String{
        get{
            name
        }
        set{
            name = newValue
        }
    }
    var description = ""
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? "n/n"
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(description, forKey: .description)
    }
    
    // sync
    
    func synchronizeFrom(_ fromData: ContentData) async{
        await super.synchronizeFrom(fromData)
        displayName = fromData.displayName
        description = fromData.description
    }
    
    override var uploadParams : Dictionary<String,String>{
        var dict = super.uploadParams
        dict["displayName"]=displayName
        dict["description"]=description
        return dict
    }
    
}

typealias ContentDataArray<T: ContentData> = Array<T>

extension ContentDataArray{
    
    var displayNames: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].displayName)
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
    
    func getContentData(displayName: String) -> ContentData?{
        for data in self{
            if data.displayName == displayName {
                return data
            }
        }
        return nil
    }
    
    mutating func sortByDisplayName(){
        self = self.sorted {
            $0.displayName < $1.displayName
        }
    }
    
}

