/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class LabeledText : UIView{
    
    private var label = UILabel()
    private var textField = UILabel()
    
    var text: String{
        get{
            return textField.text ?? ""
        }
        set{
            textField.text = newValue
        }
    }
    
    func setupView(labelText: String, text: String = "", inline: Bool = false){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        textField.text = text.isEmpty ? " " : text
        textField.textAlignment = .left
        textField.numberOfLines = 0
        textField.lineBreakMode = .byWordWrapping
        addSubview(textField)
        label.setAnchors(top: topAnchor, leading: leadingAnchor, insets: verticalInsets)
        if inline{
            label.bottom(bottomAnchor, inset: -defaultInset)
            textField.setAnchors(top: topAnchor, leading: label.trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
        }
        else{
            textField.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: verticalInsets)
        }
    }
    
}
