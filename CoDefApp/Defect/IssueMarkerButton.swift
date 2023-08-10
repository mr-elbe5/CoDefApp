/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class IssueMarkerButton: UIButton{
    
    var issue: IssueData
    
    init(issue: IssueData){
        self.issue = issue
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
    
    func updateFrame(in scopeSize: CGSize){
        guard scopeSize.width != 0 && scopeSize.height != 0 else {return}
        let x : CGFloat = issue.position.x * scopeSize.width - frame.width/2
        let y : CGFloat = issue.position.y * scopeSize.height
        frame = CGRect(x: x, y: y, width: frame.width, height: frame.height)
    }
    
    func updateIssue(in scopeSize: CGSize){
        guard scopeSize.width != 0 && scopeSize.height != 0 else {return}
        issue.position.x = (frame.minX + frame.width/2)/scopeSize.width
        issue.position.y = frame.minY/scopeSize.height
    }
    
    func updateVisibility(){
        isHidden = issue.position == .zero
    }
    
}
