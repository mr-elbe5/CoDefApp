/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

extension UITextField{
    
    func setDefaults(placeholder : String = ""){
        autocapitalizationType = .none
        autocorrectionType = .no
        self.placeholder = placeholder
        borderStyle = .roundedRect
    }
    
}

