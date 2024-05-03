/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class LabeledCheckbox : Checkbox{
    
    override func setup(title: String, index: Int = 0, data: BaseData? = nil, isOn: Bool = false){
        self.index = index
        self.title = title
        self.data = data
        self.isOn = isOn
        label.font = .preferredFont(forTextStyle: .headline)
        checkboxIcon.delegate = self
        addSubviewWithAnchors(label, top: topAnchor, leading: leadingAnchor, insets: verticalInsets)
        let vw = UIView()
        vw.backgroundColor = .systemBackground
        vw.setRoundedBorders()
        addSubviewWithAnchors(vw, top: label.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: verticalInsets)
        vw.addSubviewFilling(checkboxIcon, insets: smallInsets)
    }
    
    func setupInline(title: String, index: Int = 0, data: BaseData? = nil, isOn: Bool = false){
        self.index = index
        self.title = title
        self.data = data
        self.isOn = isOn
        label.font = .preferredFont(forTextStyle: .headline)
        checkboxIcon.delegate = self
        let vw = UIView()
        vw.backgroundColor = .systemBackground
        vw.setRoundedBorders()
        addSubviewWithAnchors(vw, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: verticalInsets)
        vw.addSubviewFilling(checkboxIcon, insets: smallInsets)
        addSubviewWithAnchors(label, top: topAnchor, leading: vw.trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
}
