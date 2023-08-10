/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import PDFKit

enum PDFTextType: String{
    case header1
    case header2
    case header3
    case label
    case text
    
    static var header1Size: CGFloat = 18.0
    static var header2Size: CGFloat = 15.0
    static var header3Size: CGFloat = 12.0
    static var labelSize: CGFloat = 12.0
    static var textSize: CGFloat = 12.0
    
    static func textAttributes(type: PDFTextType) -> TextAttributes{
        var attributes = TextAttributes()
        switch type{
        case .header1:
            attributes.setup(font: UIFont.systemFont(ofSize: header1Size, weight: .bold))
        case .header2:
            attributes.setup(font: UIFont.systemFont(ofSize: header2Size, weight: .bold))
        case .header3:
            attributes.setup(font: UIFont.systemFont(ofSize: header3Size, weight: .bold))
        case .label:
            attributes.setup(font: UIFont.systemFont(ofSize: labelSize, weight: .bold))
        case .text:
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .natural
            paragraphStyle.lineBreakMode = .byWordWrapping
            attributes.setup(paragraphStyle: paragraphStyle, font: UIFont.systemFont(ofSize: textSize))
        }
        return attributes
    }
    
    static func attributedText(_ text: String, type: PDFTextType) -> NSAttributedString{
        NSAttributedString(
            string: text,
            attributes: textAttributes(type: type)
        )
    }
}
