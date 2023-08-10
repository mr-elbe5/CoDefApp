/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
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
    
}
