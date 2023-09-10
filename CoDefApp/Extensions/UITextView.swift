/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

extension UITextView{
    
    @objc func setDefaults(){
        autocapitalizationType = .none
        autocorrectionType = .no
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.5
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
}

