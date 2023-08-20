/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import UniformTypeIdentifiers

class FileData : BaseData{
    
    private enum CodingKeys: CodingKey{
        case fileName
        //extension is reserved name
        case fileExtension
        case contentType
    }
    
    var fileName = ""
    //extension is reserved name
    var fileExtension = ""
    var contentType = ""
    
    var fileURL : URL{
        FileController.fileDirURL.appendingPathComponent(fileName)
    }
    
    override init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        fileName = try values.decode(String.self, forKey: .fileName)
        fileExtension = try values.decodeIfPresent(String.self, forKey: .fileExtension) ?? ""
        contentType = try values.decodeIfPresent(String.self, forKey: .contentType) ?? ""
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(fileExtension, forKey: .fileExtension)
        try container.encode(contentType, forKey: .contentType)
    }
    
    override func uploadParams() -> Dictionary<String,String>{
        var dict = super.uploadParams()
        dict["fileName"]=fileName
        dict["extension"]=fileExtension //extension is reserved name
        dict["contentType"]=contentType
        return dict
    }
    
    func setFileNameFromURL(_ url: URL){
        let originalFileName = url.lastPathComponent
        fileExtension = url.pathExtension
        print(fileExtension)
        let utType = UTType(filenameExtension: fileExtension)
        contentType = utType?.preferredMIMEType ?? ""
        print(contentType)
        fileName = "img_\(id).\(fileExtension)"
        print(fileName)
        Log.debug("file name from url is \(fileName) from \(originalFileName)")
    }
    
    func fileExists() -> Bool{
        return FileController.fileExists(dirPath: FileController.fileDirURL.path, fileName: fileName)
    }
    
    func getFile() -> Data?{
        let url = FileController.getURL(dirURL: FileController.fileDirURL,fileName: fileName)
        return FileController.readFile(url: url)
    }
    
    func saveFile(data: Data){
        if !fileExists(){
            let url = FileController.getURL(dirURL: FileController.fileDirURL,fileName: fileName)
            _ = FileController.saveFile(data: data, url: url)
        }
        else{
            Log.error("File exists \(fileName)")
        }
    }
    
    func deleteFile(){
        if FileController.fileExists(dirPath: FileController.fileDirURL.path, fileName: fileName){
            if !FileController.deleteFile(dirURL: FileController.fileDirURL, fileName: fileName){
                Log.error("FileData could not delete file: \(fileName)")
            }
        }
    }
    
}

