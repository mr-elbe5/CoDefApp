/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

extension UIStackView{
    
    func setupVertical(spacing: CGFloat = 0){
        self.axis = .vertical
        self.alignment = .fill
        self.distribution = .equalSpacing
        self.spacing = spacing
    }
    
    func setupHorizontal(distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0){
        self.axis = .horizontal
        self.alignment = .fill
        self.distribution = distribution
        self.spacing = spacing
    }
    
    func removeAllArrangedSubviews() {
        for subview in subviews {
            removeArrangedSubview(subview)
        }
        removeAllSubviews()
    }
    
    func addSpacer(){
        addArrangedSubview(UILabel(text: " "))
    }

}

