/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class SectionLine: UIControl{
    
    init(name: String, action: UIAction){
        super.init(frame: .zero)
        self.addAction(action, for: .touchDown)
        setGrayRoundedBorders(radius: 10)
        setBackground(.systemBackground)
        let label = UILabel(text: name)
        label.textColor = .systemBlue
        addSubviewAtLeft(label)
        let icon = IconView(icon: "chevron.right", tintColor: .systemBlue)
        addSubviewWithAnchors(icon, trailing: trailingAnchor, insets: wideInsets).centerY(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

