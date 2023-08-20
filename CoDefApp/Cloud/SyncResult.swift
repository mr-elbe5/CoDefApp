/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class SyncResult{
    
    var defectsUploaded : Int = 0
    var defectStatusesUploaded : Int = 0
    var imagesUploaded : Int = 0
    var imagesPresent : Int = 0
    
    var projectsLoaded : Int = 0
    var unitsLoaded : Int = 0
    var defectsLoaded : Int = 0
    var defectStatusesLoaded : Int = 0
    var imagesLoaded : Int = 0
    
    var uploadErrors : Int = 0
    var downloadErrors : Int = 0
    
    var itemsUploaded: Double = 0.0
    var downloadProgress: Double = 0.0
    
    var newElementsCount: Int = 0
    
    
    func hasErrors() -> Bool{
        uploadErrors > 0 || downloadErrors > 0
    }
    
    func reset(){
        defectsUploaded = 0
        defectStatusesUploaded = 0
        imagesUploaded = 0
        imagesPresent = 0
        
        projectsLoaded = 0
        unitsLoaded = 0
        defectsLoaded = 0
        defectStatusesLoaded = 0
        imagesLoaded = 0
        
        uploadErrors = 0
        downloadErrors = 0
        
        itemsUploaded = 0.0
        downloadProgress = 0.0
        
    }
    
}
