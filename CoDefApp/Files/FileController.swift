/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import Photos
import Zip

class FileController {
    
    private static let tempDir = NSTemporaryDirectory()
    static var privateURL : URL = FileManager.default.urls(for: .applicationSupportDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
    static var documentURL : URL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var imageLibraryPath: String = NSSearchPathForDirectoriesInDomains(.picturesDirectory,.userDomainMask,true).first!
    static var imageLibraryURL : URL = FileManager.default.urls(for: .picturesDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    static var imageDirURL : URL = privateURL.appendingPathComponent("images")
    static var logDirURL = documentURL.appendingPathComponent("logs")
    static var tmpDirURL = URL(fileURLWithPath: tempDir, isDirectory: true).appendingPathComponent("tmp")
    static var logFileURL = logDirURL.appendingPathComponent("log.txt")
    
    static func initializeDirectories(){
        if !FileManager.default.fileExists(atPath: imageDirURL.path){
            try? FileManager.default.createDirectory(at: imageDirURL, withIntermediateDirectories: true)
            Log.info("created media directory")
        }
    }
    
    static var tmpPath : String{
        tmpDirURL.path
    }
    
    static var privatePath : String{
        privateURL.path
    }
    
    static func initialize() {
        try! FileManager.default.createDirectory(at: FileController.privateURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.logDirURL, withIntermediateDirectories: true, attributes: nil)
        try! FileManager.default.createDirectory(at: FileController.tmpDirURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    static func getPath(dirPath: String, fileName: String ) -> String
    {
        dirPath+"/"+fileName
    }
    
    static func getURL(dirURL: URL, fileName: String ) -> URL
    {
        return dirURL.appendingPathComponent(fileName)
    }
    
    static func fileExists(dirPath: String, fileName: String) -> Bool{
        let path = getPath(dirPath: dirPath,fileName: fileName)
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func fileExists(url: URL) -> Bool{
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func isDirectory(url: URL) -> Bool{
        var isDir:ObjCBool = true
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
    }
    
    static func readFile(url: URL) -> Data?{
        if let fileData = FileManager.default.contents(atPath: url.path){
            return fileData
        }
        return nil
    }
    
    static func readTextFile(url: URL) -> String?{
        do{
            let string = try String(contentsOf: url, encoding: .utf8)
            return string
        }
        catch{
            return nil
        }
    }
    
    static func readJsonFile<T : Codable>(storeKey : String) -> T?{
        let url = privateURL.appendingPathComponent(storeKey + ".json")
        if let string = readTextFile(url: url){
            return T.fromJSON(encoded: string)
        }
        return nil
    }
    
    static func assertDirectoryFor(url: URL) -> Bool{
        let dirUrl = url.deletingLastPathComponent()
        var isDir:ObjCBool = true
        if !FileManager.default.fileExists(atPath: dirUrl.path, isDirectory: &isDir) {
            do{
                try FileManager.default.createDirectory(at: dirUrl, withIntermediateDirectories: true)
            }
            catch let err{
                Log.error("FileController could not create directory", error: err)
                return false
            }
        }
        return true
    }
    
    @discardableResult
    static func saveFile(data: Data, url: URL) -> Bool{
        do{
            try data.write(to: url, options: .atomic)
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    @discardableResult
    static func saveFile(text: String, url: URL) -> Bool{
        do{
            try text.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    @discardableResult
    static func saveJSONFile(data: Codable, storeKey : String) -> Bool{
        let value = data.toJSON()
        let url = privateURL.appendingPathComponent(storeKey + ".json")
        return saveFile(text: value, url: url)
    }
    
    @discardableResult
    static func copyFile(name: String,fromDir: URL, toDir: URL, replace: Bool = false) -> Bool{
        do{
            if replace && fileExists(url: getURL(dirURL: toDir, fileName: name)){
                _ = deleteFile(url: getURL(dirURL: toDir, fileName: name))
            }
            try FileManager.default.copyItem(at: getURL(dirURL: fromDir,fileName: name), to: getURL(dirURL: toDir, fileName: name))
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    @discardableResult
    static func copyFile(fromURL: URL, toURL: URL, replace: Bool = false) -> Bool{
        //Log.debug("FileController copying from \(fromURL.path) to \(toURL.path)")
        do{
            if replace && fileExists(url: toURL){
                _ = deleteFile(url: toURL)
            }
            try FileManager.default.copyItem(at: fromURL, to: toURL)
            return true
        } catch let err{
            Log.error("FileController", error: err)
            return false
        }
    }
    
    static func askPhotoLibraryAuthorization() async -> Bool{
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(){ granted in
                    if granted == .authorized{
                        continuation.resume(returning: true)
                    }
                    else{
                        continuation.resume(returning: false)
                    }
                }
            }
        default:
            return false
        }
    }
    
    static func copyImageToLibrary(name: String, fromDir: URL) async -> Bool{
        if await !askPhotoLibraryAuthorization(){
            return false
        }
        let url = getURL(dirURL: fromDir, fileName: name)
        if let data = readFile(url: url){
            if let image = UIImage(data: data){
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                return true
            }
        }
        return false
    }
    
    static func copyImageFromLibrary(name: String, fromDir: URL) async -> Bool{
        if await !askPhotoLibraryAuthorization(){
            return false
        }
        let url = getURL(dirURL: fromDir, fileName: name)
        if let data = readFile(url: url){
            if let image = UIImage(data: data){
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                return true
            }
        }
        return false
    }
    
    @discardableResult
    static func renameFile(dirURL: URL, fromName: String, toName: String) -> Bool{
        do{
            try FileManager.default.moveItem(at: getURL(dirURL: dirURL, fileName: fromName),to: getURL(dirURL: dirURL, fileName: toName))
            return true
        }
        catch {
            return false
        }
    }
    
    @discardableResult
    static func deleteFile(dirURL: URL, fileName: String) -> Bool{
        do{
            try FileManager.default.removeItem(at: getURL(dirURL: dirURL, fileName: fileName))
            return true
        }
        catch {
            return false
        }
    }
    
    @discardableResult
    static func deleteFile(url: URL) -> Bool{
        do{
            try FileManager.default.removeItem(at: url)
            return true
        }
        catch {
            return false
        }
    }
    
    static func listAllFiles(dirPath: String) -> Array<String>{
        return try! FileManager.default.contentsOfDirectory(atPath: dirPath)
    }
    
    static func listAllURLs(dirURL: URL) -> Array<URL>{
        let names = listAllFiles(dirPath: dirURL.path)
        var urls = Array<URL>()
        for name in names{
            urls.append(getURL(dirURL: dirURL, fileName: name))
        }
        return urls
    }
    
    static func deleteAllFiles(dirURL: URL){
        let names = listAllFiles(dirPath: dirURL.path)
        var count = 0
        for name in names{
            if deleteFile(dirURL: dirURL, fileName: name){
                count += 1
            }
        }
        if count > 0{
            Log.info("\(count) files deleted")
        }
    }
    
    static func deleteTemporaryFiles(){
        deleteAllFiles(dirURL: tmpDirURL)
    }
    
    static func deleteImageFiles(){
        deleteAllFiles(dirURL: imageDirURL)
    }
    
    static func cleanupFiles(usedNames: Array<String>) -> Int{
        var count = 0
        let names = listAllFiles(dirPath: FileController.imageDirURL.path)
        for name in names{
            if !usedNames.contains(name){
                if deleteFile(dirURL: imageDirURL, fileName: name){
                    print("deleted file: \(name)")
                    count += 1
                }
            }
        }
        return count
    }
    
    static func logFileInfo(){
        print("tmp files:")
        var names = listAllFiles(dirPath: tmpPath)
        for name in names{
            print(name)
        }
        print("img files:")
        names = listAllFiles(dirPath: FileController.imageDirURL.path)
        for name in names{
            print(name)
        }
    }
    
    static func logRestoreInfo(){
        print("files to restore:")
        let names = listAllFiles(dirPath: tmpPath)
        for name in names{
            print(name)
        }
    }
    
    static func createBackupFile(name: String) -> URL?{
        do {
            var paths = Array<URL>()
            let zipFileURL = tmpDirURL.appendingPathComponent(name)
            paths.append(imageDirURL)
            paths.append(privateURL.appendingPathComponent(AppData.storeKey + ".json"))
            paths.append(IssueData.storeDisplayIdURL)
            try Zip.zipFiles(paths: paths, zipFilePath: zipFileURL, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            return zipFileURL
        }
        catch let err {
            print(err)
            Log.error("could not create zip file")
        }
        return nil
    }
    
    static func unzipBackupFile(zipFileURL: URL) -> Bool{
        do {
            deleteTemporaryFiles()
            let destDirectory = tmpDirURL
            try FileManager.default.createDirectory(at: destDirectory, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: destDirectory, overwrite: true, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            logRestoreInfo()
            return true
        }
        catch {
            Log.error("could not read zip file")
        }
        return false
    }
    
    static func restoreBackup() -> Bool{
        deleteImageFiles()
        copyFile(fromURL: tmpDirURL.appendingPathComponent(IssueData.storeDisplayIdName), toURL: IssueData.storeDisplayIdURL, replace: true)
        IssueData.loadNextDisplayId()
        copyFile(fromURL: tmpDirURL.appendingPathComponent(AppData.storeKey + ".json"), toURL: privateURL.appendingPathComponent(AppData.storeKey + ".json"), replace: true)
        AppData.load()
        let fileNames = listAllFiles(dirPath: tmpDirURL.appendingPathComponent("images").path)
        for name in fileNames{
            copyFile(fromURL: tmpDirURL.appendingPathComponent("images").appendingPathComponent(name), toURL: imageDirURL.appendingPathComponent(name), replace: true)
        }
        deleteTemporaryFiles()
        return true
    }
    
}
