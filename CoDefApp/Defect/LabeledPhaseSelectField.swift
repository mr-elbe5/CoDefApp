/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import E5IOSUI

class LabeledPhaseSelectField : LabeledRadioGroup{
    
    func setup(labelText: String, currentPhase: ProjectPhase = .PREAPPROVAL){
        super.setupView(labelText: labelText)
        let currentIndex = PhaseList.shared.indexOf(phase: currentPhase)
        radioGroup.setup(values: PhaseList.shared.names, includingNobody: false)
        radioGroup.select(index: currentIndex)
    }
    
    var selectedPhase: ProjectPhase{
        return PhaseList.shared[selectedIndex]
    }
    
}
