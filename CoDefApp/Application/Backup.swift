/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import Photos
import Zip
import E5Data

class Backup {
    
    public static func createBackupFile(at url: URL) -> Bool{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.info("\(count) temporary files deleted before backup")
            }
            var paths = Array<URL>()
            paths.append(FileManager.fileDirURL)
            paths.append(FileManager.privateURL.appendingPathComponent(AppData.storeKey + ".json"))
            paths.append(FileManager.privateURL.appendingPathComponent(AppState.storeKey + ".json"))
            try Zip.zipFiles(paths: paths, zipFilePath: url, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return true
        }
        catch let err {
            Log.error("could not create zip file: \(err.localizedDescription)")
        }
        return false
    }
    
    public static func unzipBackupFile(zipFileURL: URL) -> Bool{
        do {
            let count = FileManager.default.deleteTemporaryFiles()
            if count > 0{
                Log.info("\(count) temporary files deleted before restore")
            }
            try FileManager.default.createDirectory(at: FileManager.tempURL, withIntermediateDirectories: true)
            try Zip.unzipFile(zipFileURL, destination: FileManager.tempURL, overwrite: true, password: nil, progress: { (progress) -> () in
                //Log.debug(progress)
            })
            return true
        }
        catch (let err){
            Log.error("could not read zip file: \(err.localizedDescription)")
        }
        return false
    }
    
    public static func restoreBackupFile() -> Bool{
        _ = FileManager.default.deleteImageFiles()
        FileManager.default.copyFile(fromURL: FileManager.tempURL.appendingPathComponent(AppData.storeKey + ".json"), toURL: FileManager.privateURL.appendingPathComponent(AppData.storeKey + ".json"), replace: true)
        FileManager.default.copyFile(fromURL: FileManager.tempURL.appendingPathComponent(AppState.storeKey + ".json"), toURL: FileManager.privateURL.appendingPathComponent(AppState.storeKey + ".json"), replace: true)
        AppState.load()
        AppData.load()
        AppState.shared.initFilter()
        let fileNames = FileManager.default.listAllFiles(dirPath: FileManager.tempURL.appendingPathComponent("files").path)
        for name in fileNames{
            FileManager.default.copyFile(fromURL: FileManager.tempURL.appendingPathComponent("files").appendingPathComponent(name), toURL: FileManager.fileDirURL.appendingPathComponent(name), replace: true)
        }
        _ = FileManager.default.deleteTemporaryFiles()
        return true
    }
    
    static func logRestoreInfo(){
        print("files to restore:")
        let names = FileManager.default.listAllFiles(dirPath: FileManager.tempURL.path)
        for name in names{
            print(name)
        }
    }
    
}
