/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

protocol SyncResultDelegate{
    func uploadChanged()
    func downloadChanged()
}

class SyncResult{
    
    var uploadedCompanies : Int = 0
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
    
    var newElementsCount: Int = 0
    
    var delegate: SyncResultDelegate? = nil
    
    func updateUpload(){
        delegate?.uploadChanged()
    }
    
    func updateDownload(){
        delegate?.downloadChanged()
    }
    
    func hasErrors() -> Bool{
        uploadErrors > 0 || downloadErrors > 0
    }
    
    func reset(){
        uploadedCompanies = 0
        uploadedProjects = 0
        uploadedUnits = 0
        uploadedDefects = 0
        uploadedStatusChanges = 0
        uploadedImages = 0
        uploadErrors = 0
        
        loadedCompanies = 0
        loadedProjects = 0
        loadedUnits = 0
        loadedDefects = 0
        loadedStatusChanges = 0
        loadedImages = 0
        presentImages = 0
        
        uploadErrors = 0
        downloadErrors = 0
        
        uploadedItems = 0.0
        
        newElementsCount = AppData.shared.countNewElements()
        
    }
    
}
