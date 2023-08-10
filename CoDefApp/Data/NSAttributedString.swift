//
//  NSAttributedString.swift
//  BandikaIssueTrackerApp
//
//  Created by Michael Rönnau on 14.05.23.
//

import Foundation
import UIKit

extension NSAttributedString{
    
    func height(width: CGFloat) -> CGFloat{
        let sz = boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading] , context: nil)
        return sz.height
    }
    
    func size(width: CGFloat) -> CGSize{
        return CGSize(width: width, height: height(width: width))
    }
    
}
