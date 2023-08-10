/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ScopePlanView: UIView{
    
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
            if subview is IssueMarkerButton{
                subview.removeFromSuperview()
            }
        }
    }
    
    @discardableResult
    func addMarker(issue: IssueData) -> IssueMarkerButton{
        let marker = IssueMarkerButton(issue: issue)
        addSubview(marker)
        marker.updateFrame(in: imageView.bounds.size)
        return marker
    }
    
    func updateMarkers(){
        for subview in subviews {
            if let marker = subview as? IssueMarkerButton{
                marker.updateFrame(in: imageView.bounds.size)
            }
        }
    }
    
}
