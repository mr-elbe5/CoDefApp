/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class ProjectViewController: ScrollViewController {
    
    var project : ProjectData
    
    var delegate: ProjectDelegate? = nil
    
    var dataSection = ArrangedSectionView()
    var unitSection = UIView()
    
    init(project: ProjectData){
        self.project = project
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "project".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "companyFilter".localize(), image: UIImage(systemName: "person.fill.viewfinder"), primaryAction: UIAction(){ action in
            let controller = CompanyFilterViewController()
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = ProjectPdfViewController(project: self.project)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if AppState.shared.standalone{
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditProjectViewController(project: self.project)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.showDestructiveApprove(text: "deleteInfo".localize()){
                AppData.shared.removeProject(self.project)
                AppData.shared.save()
                self.delegate?.projectChanged()
                self.navigationController?.popViewController(animated: true)
            }
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = ProjectInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(dataSection)
        setupDataSection()
        contentView.addSubviewAtTop(unitSection, topView: dataSection)
            .bottom(contentView.bottomAnchor)
        setupUnitSection()
    }
    
    func setupDataSection(){
        let nameLabel = LabeledText()
        nameLabel.setupView(labelText: "name".localizeWithColon(), text: project.name)
        dataSection.addArrangedSubview(nameLabel)
        
        let descriptionLabel = LabeledText()
        descriptionLabel.setupView(labelText: "description".localizeWithColon(), text: project.description)
        dataSection.addArrangedSubview(descriptionLabel)
        
        let companiesLabel = LabeledText()
        companiesLabel.setupView(labelText: "companies".localizeWithColon(), text: project.companiesText)
        dataSection.addArrangedSubview(companiesLabel)
    }
    
    func updateDataSection(){
        dataSection.removeAllArrangedSubviews()
        setupDataSection()
    }
    
    func setupUnitSection(){
        let headerLabel = UILabel(header: "units".localizeWithColon())
        unitSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        var lastView: UIView = headerLabel
        for unit in project.filteredUnits{
            let sectionLine = SectionLine(name: unit.name, action: UIAction(){ action in
                let controller = UnitViewController(unit: unit)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            unitSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: unitSection.leadingAnchor, trailing: unitSection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        let addUnitButton = TextButton(text: "newUnit".localize())
        addUnitButton.addAction(UIAction(){ (action) in
            let unit = UnitData()
            unit.project = self.project
            let controller = EditUnitViewController(unit: unit)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        unitSection.addSubviewAtTopCentered(addUnitButton, topView: lastView, insets: doubleInsets)
            .bottom(unitSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func updateUnitSection(){
        unitSection.removeAllSubviews()
        setupUnitSection()
    }
    
}

extension ProjectViewController: ProjectDelegate{
    
    func projectChanged() {
        updateDataSection()
        delegate?.projectChanged()
    }
    
}

extension ProjectViewController: UnitDelegate{
    
    func unitChanged() {
        updateUnitSection()
    }
    
}

extension ProjectViewController: FilterDelegate{
    
    func filterChanged() {
        updateUnitSection()
    }
    
}


class ProjectInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "checkmark.seal", text: "projectFilterSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "doc.text", text: "projectReportSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "projectEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "projectDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("projectUnitsInfoHeader".localize()))
        block.addArrangedSubview(InfoText("projectUnitsInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "seal", text: "projectSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "checkmark.seal", text: "projectCheckmarkSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "xmark.seal", text: "projectXmarkSealSymbolText".localize(), iconColor: .systemBlue))
    }
    
}




