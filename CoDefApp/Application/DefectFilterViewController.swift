/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class DefectFilterViewController: EditViewController {
    
    let onlyOpenCheckbox = LabeledCheckbox()
    let onlyOverdueCheckbox = LabeledCheckbox()
    
    var delegate : FilterDelegate? = nil
    
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
            let controller = DefectFilterInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView() {
        onlyOpenCheckbox.setup(title: "onlyOpenDefects".localize(), isOn: AppData.shared.filter.onlyOpen)
        contentView.addSubviewAtTop(onlyOpenCheckbox, insets: defaultInsets)
        onlyOverdueCheckbox.setup(title: "onlyOverdueDefects".localize(), isOn: AppData.shared.filter.onlyOverdue)
        contentView.addSubviewAtTop(onlyOverdueCheckbox, topView: onlyOpenCheckbox, insets: defaultInsets)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
    }
    
    override func save() -> Bool{
        AppData.shared.filter.onlyOpen = onlyOpenCheckbox.isOn
        AppData.shared.filter.onlyOverdue = onlyOverdueCheckbox.isOn
        AppData.shared.save()
        delegate?.filterChanged()
        return true
    }
 
}

class DefectFilterInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("defectFilterInfoHeader".localize()))
        block.addArrangedSubview(InfoText("defectFilterInfoText".localize()))
    }
    
}
