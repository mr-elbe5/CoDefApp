/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

struct DocumentStore {
    
    public static var shared = DocumentStore()
    
    let documentPath: String
    let documentURL : URL
    
    private init() {
        self.documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
        self.documentURL = FileManager.default.urls(for: .documentDirectory,in: FileManager.SearchPathDomainMask.userDomainMask).first!
    }
    
    private func getPath(name: String ) -> String
    {
        return documentPath+"/"+name
    }
    
    private func getURL(name: String ) -> URL
    {
        return documentURL.appendingPathComponent(name)
    }
    
    func fileExists(fileName: String) -> Bool{
        let path = getPath(name: fileName)
        return FileManager.default.fileExists(atPath: path)
    }
    
    func printFiles(){
        print("files of document directory:")
        let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentPath)
        if (fileNames != nil){
            for fileName in fileNames!{
                print(fileName)
            }
        }
    }
    
    func clearFiles(){
        var count = 0
        let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentPath)
        if (fileNames != nil){
            for fileName in fileNames!{
                do{
                    try FileManager.default.removeItem(atPath: getPath(name: fileName))
                    count += 1
                } catch let err{
                    print(err)
                }
            }
        }
        print("files deleted: " + String(count))
    }
    
    func readImage(name: String) -> UIImage?{
        let filePath = getURL(name: name)
        if let fileData = FileManager.default.contents(atPath: filePath.path){
            let image = UIImage(data: fileData)
            return image
        }
        return nil
    }
    
    func saveImage(image: UIImage, name: String){
        if let jpegRepresentation = image.jpegData(compressionQuality: 0.8){
            let url = getURL(name: name)
            do{
                try jpegRepresentation.write(to: url, options: .atomic)
                //print("saved image: \(name)")
            } catch let err{
                print("Error saving file: " + err.localizedDescription)
            }
        }
    }
    
    func renameImage(fromName: String, toName: String) -> Bool{
        do{
            try FileManager.default.moveItem(at: getURL(name: fromName),to: getURL(name: toName))
            return true
        }
        catch {
            return false
        }
    }
}
