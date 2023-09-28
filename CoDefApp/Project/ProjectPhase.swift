/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

enum ProjectPhase: String, CaseIterable{
    case PREAPPROVAL
    case APPROVAL
    case LIABILITY
}

typealias PhaseList = Array<ProjectPhase>

extension PhaseList{
    
    static var shared: PhaseList = [ProjectPhase.PREAPPROVAL, ProjectPhase.APPROVAL, ProjectPhase.LIABILITY]
    
    var names: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].rawValue.localize())
        }
        return list
    }
    
    func indexOf(phase: ProjectPhase) -> Int{
        for i in 0..<count{
            if self[i] == phase{
                return i
            }
        }
        return 0
    }
    
}

