/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import PDFKit

typealias TextAttributes = [NSAttributedString.Key: Any]

extension TextAttributes{
    
    static var defaultColor = UIColor.darkGray
    
    mutating func setup(font: UIFont){
        self[NSAttributedString.Key.font] = font
        self[NSAttributedString.Key.foregroundColor] = TextAttributes.defaultColor
    }
    
    mutating func setup(paragraphStyle: NSMutableParagraphStyle, font: UIFont){
        self[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        self[NSAttributedString.Key.font] = font
        self[NSAttributedString.Key.foregroundColor] = TextAttributes.defaultColor
    }
    
}

