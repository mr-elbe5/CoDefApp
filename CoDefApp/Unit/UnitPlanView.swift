/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class UnitPlanView: UIView{
    
    var imageView: UIImageView
    
    var plan: UIImage{
        imageView.image!
    }
    
    init(plan: UIImage){
        self.imageView = UIImageView(image: plan)
        super.init(frame: .zero)
        imageView.setAspectRatioConstraint()
        addSubviewFilling(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMarkers()
    }
    
    func removeMarkers(){
        for subview in subviews {
            if subview is DefectMarkerButton{
                subview.removeFromSuperview()
            }
        }
    }
    
    @discardableResult
    func addMarker(defect: DefectData) -> DefectMarkerButton{
        let marker = DefectMarkerButton(defect: defect)
        addSubview(marker)
        marker.updateFrame(in: imageView.bounds.size)
        return marker
    }
    
    func updateMarkers(){
        for subview in subviews {
            if let marker = subview as? DefectMarkerButton{
                marker.updateFrame(in: imageView.bounds.size)
            }
        }
    }
    
}
