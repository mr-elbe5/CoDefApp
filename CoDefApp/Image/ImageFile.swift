/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ImageFile : BaseData{
    
    private enum CodingKeys: CodingKey{
        case fileName
    }
    
    var fileName = ""
    
    var filePath : String{
        if fileName.isEmpty{
            Log.error("MediaFile file has no name")
            return ""
        }
        return FileController.getPath(dirPath: FileController.imageDirURL.path,fileName: fileName)
    }
    
    var fileURL : URL{
        if fileName.isEmpty{
            Log.error("MediaFile file has no name")
        }
        return FileController.getURL(dirURL: FileController.imageDirURL,fileName: fileName)
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileName = try values.decode(String.self, forKey: .fileName)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
    }
    
    override func asDictionary() -> Dictionary<String,String>{
        var dict = super.asDictionary()
        dict["fileName"]=fileName
        return dict
    }
    
    func setFileNameFromURL(_ url: URL){
        var name = url.lastPathComponent
        //Log.debug("file name from url is \(name)")
        fileName = name
        if fileExists(){
            Log.info("cannot use file name \(fileName)")
            var count = 1
            var ext = ""
            if let pntPos = name.lastIndex(of: "."){
                ext = String(name[pntPos...])
                name = String(name[..<pntPos])
            }
            do{
                fileName = "\(name)(\(count))\(ext)"
                if !fileExists(){
                    Log.info("new file name is \(fileName)")
                    return
                }
                count += 1
            }
        }
    }
    
    func setJpegFileName(){
        fileName = "img_\(id).jpg"
    }
    
    func fileExists() -> Bool{
        return FileController.fileExists(dirPath: FileController.imageDirURL.path, fileName: fileName)
    }
    
    func getFile() -> Data?{
        let url = FileController.getURL(dirURL: FileController.imageDirURL,fileName: fileName)
        return FileController.readFile(url: url)
    }
    
    func getImage() -> UIImage{
        if let data = getFile(), let image = UIImage(data: data){
            return image
        } else{
            return UIImage()
        }
    }
    
    func saveFile(data: Data){
        if !fileExists(){
            let url = FileController.getURL(dirURL: FileController.imageDirURL,fileName: fileName)
            _ = FileController.saveFile(data: data, url: url)
        }
        else{
            Log.error("ImageFile exists \(fileName)")
        }
    }
    
    func saveImage(uiImage: UIImage){
        if let data = uiImage.jpegData(compressionQuality: 0.8){
            saveFile(data: data)
        }
    }
    
    func deleteFile(){
        if FileController.fileExists(dirPath: FileController.imageDirURL.path, fileName: fileName){
            if !FileController.deleteFile(dirURL: FileController.imageDirURL, fileName: fileName){
                Log.error("FileData could not delete file: \(fileName)")
            }
        }
    }
    
}

protocol ImageFileViewDelegate{
    func viewImage(image: ImageFile, imageDeleteDelegate: ImageFileDeleteDelegate?)
}

protocol ImageFileDeleteDelegate{
    func deleteImage(image: ImageFile)
}
