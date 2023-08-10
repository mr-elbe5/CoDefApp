/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class FilteredSectionLine: UIControl{
    
    init(name: String, filtered: Bool, enabled: Bool, action: UIAction){
        super.init(frame: .zero)
        self.addAction(action, for: .touchDown)
        setGrayRoundedBorders(radius: 10)
        setBackground(.systemBackground)
        let label = UILabel(text: name)
        label.textColor = enabled ? .systemBlue : .label
        addSubviewAtLeft(label)
        let icon = IconView(icon: filtered ? (enabled ? "checkmark.seal" : "xmark.seal") : "seal", tintColor: enabled ? .systemBlue : .label)
        addSubviewAtLeft(icon, leadingView: label)
        if !filtered || enabled{
            let icon = IconView(icon: "chevron.right", tintColor: .systemBlue)
            addSubviewWithAnchors(icon, trailing: trailingAnchor, insets: wideInsets).centerY(centerYAnchor)
        }
        self.isEnabled = enabled
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

