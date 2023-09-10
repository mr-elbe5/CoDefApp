/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

extension UILabel{
    
    func setDefaults(text : String){
        self.text = text
    }
    
    convenience init(text: String){
        self.init()
        self.text = text
        numberOfLines = 0
        textColor = .label
    }
    
    convenience init(header: String){
        self.init()
        self.text = header
        font = .preferredFont(forTextStyle: .headline)
        numberOfLines = 0
        textColor = .label
    }
    
}

