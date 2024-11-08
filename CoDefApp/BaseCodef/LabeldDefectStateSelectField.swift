/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class LabeledDefectStatusSelectView : LabeledRadioGroup{
    
    func setupStatuses( currentStatus: DefectStatus? = nil){
        var values = Array<String>()
        var currentIndex = 0
        for statuses in DefectStatus.allCases{
            values.append(statuses.rawValue.localize())
            if statuses == currentStatus{
                currentIndex = values.count - 1
            }
        }
        radioGroup.setup(values: values)
        radioGroup.select(index: currentIndex)
    }
    
    var selectedStatus: DefectStatus{
        let statuses = DefectStatus.allCases
        return statuses[selectedIndex]
    }
    
}
