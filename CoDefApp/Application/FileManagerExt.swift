/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

extension FileManager {
    
    static var fileDirURL : URL = privateURL.appendingPathComponent("files")
    static let documentURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var logDirURL = documentURL.appendingPathComponent("logs")
    static var logFileURL = logDirURL.appendingPathComponent("log.txt")
    
    func initialize() {
        try! createDirectory(at: FileManager.logDirURL, withIntermediateDirectories: true, attributes: nil)
        try! createDirectory(at: FileManager.fileDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func deleteImageFiles() -> Int{
        deleteAllFiles(dirURL: FileManager.fileDirURL)
    }

    func cleanupFiles(usedNames: Array<String>) -> Int{
        var count = 0
        let names = listAllFiles(dirPath: FileManager.fileDirURL.path)
        for name in names{
            if !usedNames.contains(name){
                if deleteFile(dirURL: FileManager.fileDirURL, fileName: name){
                    print("deleted file: \(name)")
                    count += 1
                }
            }
        }
        return count
    }
    
}
