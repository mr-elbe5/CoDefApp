/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

extension URL {
    
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }

}
