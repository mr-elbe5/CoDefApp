/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

enum DefectStatus: String, CaseIterable{
    case open
    case disputed
    case rejected
    case done
}
