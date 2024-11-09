/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

protocol TouchDelegate{
    func touched(at relativePosition: CGPoint)
}

class ImageScrollView: UIScrollView, UIScrollViewDelegate{
    
    var image: UIImage
    var imageView: UIImageView
    
    var touchDelegate: TouchDelegate? = nil
    
    init(image: UIImage) {
        self.image = image
        imageView = UIImageView(image: image)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        isScrollEnabled = true
        scrollsToTop = false
        isDirectionalLockEnabled = false
        isPagingEnabled = false
        showsVerticalScrollIndicator = true
        showsHorizontalScrollIndicator = true
        bounces = false
        bouncesZoom = false
        maximumZoomScale = 2.0
        minimumZoomScale = 1.0
        addSubview(imageView)
        contentSize = image.size
        delegate = self
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (onTouch))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func onTouch(_ sender: UIGestureRecognizer){
        let point = sender.location(in: imageView)
        touched(pnt: point)
    }
    
    func touched(pnt: CGPoint){
        touchDelegate?.touched(at: CGPoint(x: pnt.x/image.size.width, y: pnt.y/image.size.height))
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
}
