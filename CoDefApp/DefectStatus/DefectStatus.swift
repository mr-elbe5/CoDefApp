/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

enum DefectStatus: String, CaseIterable{
    case OPEN
    case DISPUTED
    case REJECTED
    case DONE
}
