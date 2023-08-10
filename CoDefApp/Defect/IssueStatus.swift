/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

enum IssueStatus: String, CaseIterable{
    case open
    case disputed
    case rejected
    case done
}
