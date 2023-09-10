/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

extension TimeInterval{
    
    func hmsString() -> String {
        
        let time = Int(self)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
}
