/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

typealias CompanyList = Array<CompanyData>

extension CompanyList{
    
    var names: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].name)
        }
        return list
    }
    
    func company(withId id: Int)-> CompanyData?{
        for company in self{
            if company.id == id{
                return company
            }
        }
        return nil
    }
    
}
