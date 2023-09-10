/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class CompanyFilterViewController: EditViewController {
    
    var labeledCheckboxGroup = LabeledCheckboxGroup()
    
    var delegate : FilterDelegate? = nil
    
    override func loadView() {
        title = "companyFilter".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "cancel".localize(), primaryAction: UIAction(){ action in
            self.navigationController?.popViewController(animated: true)
        }))
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = CompanyFilterInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView() {
        labeledCheckboxGroup.setupView(labelText: "onlyForCompanies".localizeWithColon())
        contentView.addSubviewAtTop(labeledCheckboxGroup, insets: defaultInsets)
            .bottom(contentView.bottomAnchor)
        
        for company in AppData.shared.companies{
            let checkbox = Checkbox()
            checkbox.setup(title: company.name, data: company, isOn: AppState.shared.filter.companyIds.contains(company.id))
            labeledCheckboxGroup.addCheckbox(cb: checkbox)
        }
        
    }
    
    override func save() -> Bool{
        AppState.shared.filter.companyIds.removeAll()
        for checkbox in labeledCheckboxGroup.checkboxGroup.checkboxViews{
            if let company = checkbox.data as? CompanyData, checkbox.isOn{
                AppState.shared.filter.companyIds.append(company.id)
            }
        }
        AppState.shared.save()
        delegate?.filterChanged()
        return true
    }
 
}

class CompanyFilterInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("companyFilterInfoHeader".localize()))
        block.addArrangedSubview(InfoText("companyFilterInfoText".localize()))
    }
    
}
