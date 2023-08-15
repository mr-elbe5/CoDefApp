/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class FilterViewController: EditViewController {
    
    var project: ProjectData
    
    let onlyOpenCheckbox = LabeledCheckbox()
    let onlyOverdueCheckbox = LabeledCheckbox()
    let companySelectField = LabeledCompanySelectField()
    
    var delegate : FilterDelegate? = nil
    
    init(project: ProjectData){
        self.project = project
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "filter".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "cancel".localize(), primaryAction: UIAction(){ action in
            self.navigationController?.popViewController(animated: true)
        }))
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = FilterInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView() {
        onlyOpenCheckbox.setup(title: "onlyOpenDefects".localize(), isOn: project.filter.onlyOpen)
        contentView.addSubviewAtTop(onlyOpenCheckbox, insets: defaultInsets)
        onlyOverdueCheckbox.setup(title: "onlyOverdueDefects".localize(), isOn: project.filter.onlyOverdue)
        contentView.addSubviewAtTop(onlyOverdueCheckbox, topView: onlyOpenCheckbox, insets: defaultInsets)
        companySelectField.setupView(labelText: "onlyForCompany".localize())
        companySelectField.setupCompanies(companies: project.companies, currentCompanyId: project.filter.companyId, includingNobody: true)
        contentView.addSubviewAtTop(companySelectField, topView: onlyOverdueCheckbox, insets: defaultInsets)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
    }
    
    override func save() -> Bool{
        project.filter.onlyOpen = onlyOpenCheckbox.isOn
        project.filter.onlyOverdue = onlyOverdueCheckbox.isOn
        project.filter.companyId = companySelectField.selectedCompany?.id ?? 0
        project.saveData()
        delegate?.filterChanged()
        return true
    }
 
}

class FilterInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("filterInfoHeader".localize()))
        block.addArrangedSubview(InfoText("filterInfoText".localize()))
    }
    
}
