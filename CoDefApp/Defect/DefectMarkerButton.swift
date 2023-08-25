/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class DefectMarkerButton: UIButton{
    
    var defect: DefectData
    
    init(defect: DefectData){
        self.defect = defect
        let img = UIImage(named: "redArrow")!
        super.init(frame: CGRect(x: -img.size.width/2, y: 0, width: img.size.width, height: img.size.height))
        setImage(UIImage(named: "redArrow"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveTo(pnt: CGPoint){
        frame = CGRect(x: pnt.x - frame.width/2, y: pnt.y, width: frame.width, height: frame.width)
    }
    
    func updateFrame(in unitSize: CGSize){
        guard unitSize.width != 0 && unitSize.height != 0 else {return}
        let x : CGFloat = defect.position.x * unitSize.width - frame.width/2
        let y : CGFloat = defect.position.y * unitSize.height
        frame = CGRect(x: x, y: y, width: frame.width, height: frame.height)
    }
    
    func updateDefect(in unitSize: CGSize){
        guard unitSize.width != 0 && unitSize.height != 0 else {return}
        defect.position.x = (frame.minX + frame.width/2)/unitSize.width
        defect.position.y = frame.minY/unitSize.height
    }
    
    func updateVisibility(){
        isHidden = defect.position == .zero
    }
    
}
