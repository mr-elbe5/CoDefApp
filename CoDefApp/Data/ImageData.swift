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
    
    func saveImage(uiImage: UIImage){
        if let data = uiImage.jpegData(compressionQuality: 0.8){
            saveFile(data: data)
        }
    }
    
    func uploadToServer(contentId: Int) async{
        if !isOnServer{
            do{
                let uiImage = getImage()
                let requestUrl = "\(AppState.shared.serverURL)/api/image/uploadImage/\(id)?contentId=\(contentId)"
                if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: fileName) {
                    print("image \(id) uploaded with new id \(response.id)")
                    id = response.id
                    isOnServer = true
                    saveData()
                    await AppState.shared.imageUploaded()
                }
                else{
                    throw "image upload error"
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
