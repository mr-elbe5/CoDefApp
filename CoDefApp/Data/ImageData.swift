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
    
    override var serverFileName: String{
        "img_\(localId)_\(id).\(fileExtension)"
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
    
    func upload(contentId: Int, syncResult: SyncResult) async{
        do{
            let uiImage = getImage()
            let requestUrl = AppState.shared.serverURL+"/api/image/uploadImage/" + String(contentId) + "?imageId=" + String(id)
            if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: serverFileName) {
                print("image uploaded with id \(response.id)")
                id = response.id
                synchronized = true
                await MainActor.run{
                    syncResult.imageUploaded()
                }
            }
            else{
                throw "image upload error"
            }
        }
        catch{
            await MainActor.run{
                syncResult.uploadError()
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
