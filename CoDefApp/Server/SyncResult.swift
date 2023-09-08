/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

protocol SyncResultDelegate{
    func updateUploadView()
    func updateDownloadView()
}

class SyncResult{
    
    var uploadedProjects : Int = 0
    var uploadedUnits : Int = 0
    var uploadedDefects : Int = 0
    var uploadedStatusChanges : Int = 0
    var uploadedImages : Int = 0
    var uploadedItems: Double = 0.0
    var uploadErrors : Int = 0
    
    var loadedCompanies : Int = 0
    var loadedProjects : Int = 0
    var loadedUnits : Int = 0
    var loadedDefects : Int = 0
    var loadedStatusChanges : Int = 0
    var loadedImages : Int = 0
    var presentImages : Int = 0
    var downloadErrors : Int = 0
    
    var unsynchronizedElementsCount: Int = 0
    
    var delegate: SyncResultDelegate? = nil
    
    func imageUploaded(){
        unsynchronizedElementsCount -= 1
        uploadedImages += 1
        uploadedItems += 1.0
        delegate?.updateUploadView()
    }
    
    func projectUploaded(){
        unsynchronizedElementsCount -= 1
        uploadedItems += 1.0
        delegate?.updateUploadView()
    }
    
    func unitUploaded(){
        unsynchronizedElementsCount -= 1
        uploadedItems += 1.0
        delegate?.updateUploadView()
    }
    
    func defectUploaded(){
        unsynchronizedElementsCount -= 1
        uploadedItems += 1.0
        delegate?.updateUploadView()
    }
    
    func statusChangeUploaded(){
        unsynchronizedElementsCount -= 1
        uploadedItems += 1.0
        delegate?.updateUploadView()
    }
    
    func uploadError(){
        uploadErrors += 1
        delegate?.updateUploadView()
    }
    
    func updateDownload(){
        delegate?.updateDownloadView()
    }
    
    func downloadError(){
        downloadErrors += 1
        delegate?.updateDownloadView()
    }
    
    func hasErrors() -> Bool{
        uploadErrors > 0 || downloadErrors > 0
    }
    
    func resetUpload(){
        uploadedProjects = 0
        uploadedUnits = 0
        uploadedDefects = 0
        uploadedStatusChanges = 0
        uploadedImages = 0
        uploadErrors = 0
        uploadErrors = 0
        uploadedItems = 0.0
        
    }
    
    func setUnsynchronizedElementCount(){
        unsynchronizedElementsCount = AppData.shared.countUnsynchronizedElements()
    }
    
    func resetDownload(){
        loadedCompanies = 0
        loadedProjects = 0
        loadedUnits = 0
        loadedDefects = 0
        loadedStatusChanges = 0
        loadedImages = 0
        presentImages = 0
        downloadErrors = 0
    }
    
    func reset(){
        resetUpload()
        resetDownload()
    }
    
}
