/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

typealias AppDate = Date

extension AppDate{
    
    func asString() -> String{
        AppState.shared.useDateTime ? dateTimeString() : dateString()
    }
    
}
