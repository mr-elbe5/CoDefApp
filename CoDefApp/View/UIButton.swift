/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

extension UIButton{
    
    @discardableResult
    func asIconButton(_ icon: String, color: UIColor = .darkGray) -> UIButton{
        setImage(UIImage(systemName: icon), for: .normal)
        self.tintColor = color
        self.scaleBy(1.25)
        return self
    }
    
    @discardableResult
    func asImageButton(_ image: String) -> UIButton{
        setImage(UIImage(named: image), for: .normal)
        return self
    }

    @discardableResult
    func asTextButton(_ text: String, color: UIColor = .systemBlue, backgroundColor: UIColor? = nil) -> UIButton{
        setTitle(text, for: .normal)
        setTitleColor(color, for: .normal)
        tintColor = color
        if let bgcol = backgroundColor{
            self.backgroundColor = bgcol
            layer.cornerRadius = 5
            layer.masksToBounds = true
        }
        return self
    }
    
}

