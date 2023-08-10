/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class FilterViewController: EditViewController {
    
    var project: ProjectData
    
    let onlyOpenCheckbox = LabeledCheckbox()
    let onlyOverdueCheckbox = LabeledCheckbox()
    let userSelectField = LabeledUserSelectField()
    
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
        onlyOpenCheckbox.setup(title: "onlyOpenIssues".localize(), isOn: project.filter.onlyOpen)
        contentView.addSubviewAtTop(onlyOpenCheckbox, insets: defaultInsets)
        onlyOverdueCheckbox.setup(title: "onlyOverdueIssues".localize(), isOn: project.filter.onlyOverdue)
        contentView.addSubviewAtTop(onlyOverdueCheckbox, topView: onlyOpenCheckbox, insets: defaultInsets)
        userSelectField.setupView(labelText: "onlyForUser".localize())
        userSelectField.setupUsers(users: project.users, currentUserId: project.filter.userId, includingNobody: true)
        contentView.addSubviewAtTop(userSelectField, topView: onlyOverdueCheckbox, insets: defaultInsets)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
    }
    
    override func save() -> Bool{
        project.filter.onlyOpen = onlyOpenCheckbox.isOn
        project.filter.onlyOverdue = onlyOverdueCheckbox.isOn
        project.filter.userId = userSelectField.selectedUser?.uuid ?? .NIL
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
