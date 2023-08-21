/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class ContentData : BaseData{
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
    }
    
    var name = ""
    var description = ""
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["name"]=name
        dict["description"]=description
        return dict
    }
    
    func uploadImage(requestUrl: String, image: ImageData, fileName: String, syncResult: SyncResult) async{
        do{
            let uiImage = image.getImage()
            if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: fileName) {
                print("unit image uploaded with id \(response.id)")
                image.id = response.id
                await MainActor.run{
                    syncResult.newElementsCount -= 1
                    syncResult.uploadedImages += 1
                    syncResult.uploadedItems += 1.0
                    syncResult.updateUpload()
                }
            }
            else{
                throw "image upload error"
            }
        }
        catch{
            await MainActor.run{
                syncResult.uploadErrors += 1
                syncResult.updateUpload()
            }
        }
    }
    
}

