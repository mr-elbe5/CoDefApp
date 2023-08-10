/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class LabeledIssueStatusSelectView : LabeledRadioGroup{
    
    func setupStatuses( currentStatus: IssueStatus? = nil){
        var values = Array<String>()
        var currentIndex = 0
        for statuses in IssueStatus.allCases{
            values.append(statuses.rawValue.localize())
            if statuses == currentStatus{
                currentIndex = values.count - 1
            }
        }
        radioGroup.setup(values: values)
        radioGroup.select(index: currentIndex)
    }
    
    var selectedStatus: IssueStatus{
        let statuses = IssueStatus.allCases
        return statuses[selectedIndex]
    }
    
}
