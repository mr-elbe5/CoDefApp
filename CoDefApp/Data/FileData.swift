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
        FileManager.fileDirURL.appendingPathComponent(fileName)
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
    
    override var uploadParams: Dictionary<String,String>{
        var dict = super.uploadParams
        dict["fileName"]=fileName
        dict["extension"]=fileExtension //extension is reserved name
        dict["contentType"]=contentType
        return dict
    }
    
    func synchronizeFrom(_ fromData: FileData) async{
        await super.synchronizeFrom(fromData)
        fileName = fromData.fileName
        fileExtension = fromData.fileExtension
        contentType = fromData.contentType
    }
    
    func setFileNameFromURL(_ url: URL){
        fileExtension = url.pathExtension
        let utType = UTType(filenameExtension: fileExtension)
        contentType = utType?.preferredMIMEType ?? ""
        fileName = "img_\(id).\(fileExtension)"
        //Log.debug("file name from url is \(fileName) from \(originalFileName)")
    }
    
    func fileExists() -> Bool{
        return FileManager.default.fileExists(dirPath: FileManager.fileDirURL.path, fileName: fileName)
    }
    
    func getFile() -> Data?{
        let url = FileManager.fileDirURL.appendingPathComponent(fileName)
        return FileManager.default.readFile(url: url)
    }
    
    func saveFile(data: Data) -> Bool{
        if !fileExists(){
            let url = FileManager.fileDirURL.appendingPathComponent(fileName)
            return FileManager.default.saveFile(data: data, url: url)
        }
        else{
            Log.error("File exists \(fileName)")
        }
        return false
    }
    
    func deleteFile(){
        if FileManager.default.fileExists(dirPath: FileManager.fileDirURL.path, fileName: fileName){
            if !FileManager.default.deleteFile(dirURL: FileManager.fileDirURL, fileName: fileName){
                Log.error("FileData could not delete file: \(fileName)")
            }
        }
    }
    
}

typealias FileList = BaseDataArray<FileData>

extension FileList{
    
    func getFileData(id: Int) -> FileData?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}
