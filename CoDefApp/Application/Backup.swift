/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import Photos
import Zip

class Backup {
    
    static func logRestoreInfo(){
        print("files to restore:")
        let names = FileController.listAllFiles(dirPath: FileController.tmpPath)
        for name in names{
            print(name)
        }
    }
    
    static func createBackupFile(name: String) -> URL?{
        do {
            var paths = Array<URL>()
            let zipFileURL = FileController.tmpDirURL.appendingPathComponent(name)
            paths.append(FileController.fileDirURL)
            paths.append(FileController.privateURL.appendingPathComponent(AppData.storeKey + ".json"))
            paths.append(FileController.privateURL.appendingPathComponent(AppState.storeKey + ".json"))
            paths.append(DefectData.storeDisplayIdURL)
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
            FileController.deleteTemporaryFiles()
            let destDirectory = FileController.tmpDirURL
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
        FileController.deleteImageFiles()
        FileController.copyFile(fromURL: FileController.tmpDirURL.appendingPathComponent(DefectData.storeDisplayIdName), toURL: DefectData.storeDisplayIdURL, replace: true)
        DefectData.loadNextDisplayId()
        FileController.copyFile(fromURL: FileController.tmpDirURL.appendingPathComponent(AppData.storeKey + ".json"), toURL: FileController.privateURL.appendingPathComponent(AppData.storeKey + ".json"), replace: true)
        FileController.copyFile(fromURL: FileController.tmpDirURL.appendingPathComponent(AppState.storeKey + ".json"), toURL: FileController.privateURL.appendingPathComponent(AppState.storeKey + ".json"), replace: true)
        AppState.load()
        AppData.load()
        AppState.shared.initFilter()
        let fileNames = FileController.listAllFiles(dirPath: FileController.tmpDirURL.appendingPathComponent("files").path)
        for name in fileNames{
            FileController.copyFile(fromURL: FileController.tmpDirURL.appendingPathComponent("files").appendingPathComponent(name), toURL: FileController.fileDirURL.appendingPathComponent(name), replace: true)
        }
        FileController.deleteTemporaryFiles()
        return true
    }
    
}
