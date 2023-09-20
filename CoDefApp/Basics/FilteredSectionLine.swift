import Foundation
import UIKit

class FilteredSectionLine: UIControl{
    
    init(name: String, inFilter: Bool, action: UIAction){
        super.init(frame: .zero)
        self.addAction(action, for: .touchDown)
        setGrayRoundedBorders(radius: 10)
        setBackground(.systemBackground)
        let label = UILabel(text: name)
        label.textColor = .systemBlue
        addSubviewAtLeft(label)
        let filterIcon = IconView(icon: inFilter ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.xmark", tintColor: inFilter ? .systemBlue : .lightGray)
        addSubviewAtLeft(filterIcon, leadingView: label, insets: UIEdgeInsets(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: 0))
        let icon = IconView(icon: "chevron.right", tintColor: .systemBlue)
        addSubviewWithAnchors(icon, trailing: trailingAnchor, insets: wideInsets).centerY(centerYAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

