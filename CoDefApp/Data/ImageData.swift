/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import UniformTypeIdentifiers

class ImageData : FileData{
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func setJpegFileName(){
        fileName = "img_\(id).jpg"
        fileExtension = "jpg"
        contentType = "image/jpeg"
    }
    
    func getImage() -> UIImage{
        if let data = getFile(), let image = UIImage(data: data){
            return image
        } else{
            return UIImage()
        }
    }
    
    func saveJpegImage(uiImage: UIImage) -> Bool{
        if let data = uiImage.jpegData(compressionQuality: 0.85){
            return saveFile(data: data)
        }
        return false
    }
    
    func uploadToServer(contentId: Int) async{
        if !isOnServer{
            do{
                let uiImage = getImage()
                let requestUrl = "\(AppState.shared.serverURL)/api/image/uploadImage/\(id)?contentId=\(contentId)&creatorId=\(creatorId)&changerId=\(changerId)&creationDate=\(creationDate.isoString())"
                if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: fileName, contentType: contentType) {
                    print("image \(id) uploaded with new id \(response.id)")
                    id = response.id
                    isOnServer = true
                    saveData()
                    await AppState.shared.imageUploaded()
                }
                else{
                    throw GenericError("image upload error")
                }
            }
            catch{
                await AppState.shared.uploadError()
            }
        }
    }
    
}

typealias ImageList = BaseDataArray<ImageData>

extension ImageList{
    
    func getImageData(id: Int) -> ImageData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol ImageFileViewDelegate{
    func viewImage(image: ImageData, imageDeleteDelegate: ImageFileDeleteDelegate?)
}

protocol ImageFileDeleteDelegate{
    func deleteImage(image: ImageData)
}
