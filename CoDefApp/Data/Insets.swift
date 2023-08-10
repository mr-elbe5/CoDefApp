/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

import UIKit

struct Insets{
    
    static var defaultInset : CGFloat = 10
    
    static var smallInset : CGFloat = 5
    
    static var defaultInsets : UIEdgeInsets = .init(top: defaultInset, left: defaultInset, bottom: defaultInset, right: defaultInset)
    
    static var smallInsets : UIEdgeInsets = .init(top: smallInset, left: smallInset, bottom: smallInset, right: smallInset)
    
    static var horizontalInsets : UIEdgeInsets = .init(top: 0, left: defaultInset, bottom: 0, right: defaultInset)
    
    static var horizontalDoubleInsets : UIEdgeInsets = .init(top: 0, left: 2*defaultInset, bottom: 0, right: 2*defaultInset)
    
    static var verticalInsets : UIEdgeInsets = .init(top: defaultInset, left: 0, bottom: defaultInset, right: 0)
    
    static var wideInsets : UIEdgeInsets = .init(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: 2*defaultInset)
    
    static var reverseDefaultInsets : UIEdgeInsets = .init(top: -defaultInset, left: -defaultInset, bottom: -defaultInset, right: -defaultInset)
    
    static var doubleInsets : UIEdgeInsets = .init(top: 2 * defaultInset, left: 2 * defaultInset, bottom: 2 * defaultInset, right: 2 * defaultInset)
    
    static var topIconInsets : UIEdgeInsets = .init(top: smallInset, left: defaultInset, bottom: smallInset, right: defaultInset)
    
}

