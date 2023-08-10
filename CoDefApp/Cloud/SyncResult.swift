/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class SyncResult{
    
    var issuesUploaded : Int = 0
    var feedbacksUploaded : Int = 0
    var imagesUploaded : Int = 0
    var imagesPresent : Int = 0
    
    var projectsLoaded : Int = 0
    var scopesLoaded : Int = 0
    var issuesLoaded : Int = 0
    var imagesLoaded : Int = 0
    
    var uploadErrors : Int = 0
    var downloadErrors : Int = 0
    
    var progress: Double = 0.0
    
    var newElementsCount: Int = 0
    
    func hasErrors() -> Bool{
        uploadErrors > 0 || downloadErrors > 0
    }
    
    func reset(){
        issuesUploaded = 0
        feedbacksUploaded = 0
        imagesUploaded = 0
        imagesPresent = 0
        
        projectsLoaded = 0
        scopesLoaded = 0
        issuesLoaded = 0
        imagesLoaded = 0
        
        uploadErrors = 0
        downloadErrors = 0
        
        progress = 0.0
        
    }
    
}
