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
    
    static func logRestoreInfo(){
        print("files to restore:")
        let names = FileManager.default.listAllFiles(dirPath: FileManager.tempDir)
        for name in names{
            print(name)
        }
    }
    
    static func createBackupFile(name: String) -> URL?{
        do {
            var paths = Array<URL>()
            let zipFileURL = FileManager.tmpDirURL.appendingPathComponent(name)
            paths.append(FileManager.fileDirURL)
            paths.append(FileManager.privateURL.appendingPathComponent(AppData.storeKey + ".json"))
            paths.append(FileManager.privateURL.appendingPathComponent(AppState.storeKey + ".json"))
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
            _ = FileManager.default.deleteTemporaryFiles()
            let destDirectory = FileManager.tmpDirURL
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
        _ = FileManager.default.deleteImageFiles()
        FileManager.default.copyFile(fromURL: FileManager.tmpDirURL.appendingPathComponent(AppData.storeKey + ".json"), toURL: FileManager.privateURL.appendingPathComponent(AppData.storeKey + ".json"), replace: true)
        FileManager.default.copyFile(fromURL: FileManager.tmpDirURL.appendingPathComponent(AppState.storeKey + ".json"), toURL: FileManager.privateURL.appendingPathComponent(AppState.storeKey + ".json"), replace: true)
        AppState.load()
        AppData.load()
        AppState.shared.initFilter()
        let fileNames = FileManager.default.listAllFiles(dirPath: FileManager.tmpDirURL.appendingPathComponent("files").path)
        for name in fileNames{
            FileManager.default.copyFile(fromURL: FileManager.tmpDirURL.appendingPathComponent("files").appendingPathComponent(name), toURL: FileManager.fileDirURL.appendingPathComponent(name), replace: true)
        }
        _ = FileManager.default.deleteTemporaryFiles()
        return true
    }
    
}
