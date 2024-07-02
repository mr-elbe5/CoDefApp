/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import E5IOSUI

class LabeledCompanySelectField : LabeledRadioGroup{
    
    var companies: CompanyList? = nil
    
    func setupCompanies(companies: CompanyList, currentCompanyId: Int = 0, includingNobody: Bool = false){
        self.companies = companies
        var values = Array<String>()
        var currentIndex = -1
        for company in companies{
            values.append(company.name)
            if company.id == currentCompanyId{
                currentIndex = values.count - 1
            }
        }
        radioGroup.setup(values: values, includingNobody: includingNobody)
        if currentIndex != -1 || includingNobody{
            radioGroup.select(index: currentIndex)
        }
    }
    
    var selectedCompany: CompanyData?{
        if selectedIndex != -1, let companies = companies{
            return companies[selectedIndex]
        }
        return nil
    }
    
}
