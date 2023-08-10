/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class ProjectViewController: ScrollViewController {
    
    var project : ProjectData
    
    var delegate: ProjectDelegate? = nil
    
    var filterItem: UIBarButtonItem? = nil
    
    var dataSection = ArrangedSectionView()
    var scopeSection = UIView()
    
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
        filterItem = UIBarButtonItem(title: "filter".localize(), image: UIImage(systemName: project.filter.active ? "checkmark.seal" : "seal"), primaryAction: UIAction(){ action in
            let controller = FilterViewController(project: self.project)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        })
        items.append(filterItem!)
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = ProjectPdfViewController(project: self.project)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if CurrentUser.hasEditRight(for: project){
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditProjectViewController(project: self.project)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
                self.showDestructiveApprove(text: "deleteInfo".localize()){
                    AppData.shared.removeProject(self.project)
                    AppData.shared.save()
                    self.delegate?.projectChanged()
                    self.navigationController?.popViewController(animated: true)
                }
            }))
        }
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = ProjectInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    func updateFilterItem(){
        filterItem?.image =  UIImage(systemName: project.filter.active ? "checkmark.seal" : "seal")
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(dataSection)
        setupDataSection()
        contentView.addSubviewAtTop(scopeSection, topView: dataSection)
            .bottom(contentView.bottomAnchor)
        setupScopeSection()
    }
    
    func setupDataSection(){
        let nameLabel = LabeledText()
        nameLabel.setupView(labelText: "name".localizeWithColon(), text: project.name)
        dataSection.addArrangedSubview(nameLabel)
        
        let descriptionLabel = LabeledText()
        descriptionLabel.setupView(labelText: "description".localizeWithColon(), text: project.description)
        dataSection.addArrangedSubview(descriptionLabel)
    }
    
    func updateDataSection(){
        dataSection.removeAllArrangedSubviews()
        setupDataSection()
    }
    
    func setupScopeSection(){
        let headerLabel = UILabel(header: "scopes".localizeWithColon())
        scopeSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        var lastView: UIView = headerLabel
        let filteredScopes = project.filteredScopes
        let filterActive = project.isFilterActive

        for scope in project.scopes{
            let sectionLine = FilteredSectionLine(name: scope.name, filtered: filterActive, enabled: filteredScopes.contains(scope), action: UIAction(){ action in
                let controller = UnitViewController(scope: scope)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            scopeSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: scopeSection.leadingAnchor, trailing: scopeSection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        let addScopeButton = TextButton(text: "newScope".localize())
        addScopeButton.addAction(UIAction(){ (action) in
            let scope = UnitData()
            scope.project = self.project
            let controller = EditUnitViewController(scope: scope)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        scopeSection.addSubviewAtTopCentered(addScopeButton, topView: lastView, insets: doubleInsets)
            .bottom(scopeSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func updateScopeSection(){
        scopeSection.removeAllSubviews()
        setupScopeSection()
    }
    
}

extension ProjectViewController: ProjectDelegate{
    
    func projectChanged() {
        updateDataSection()
        delegate?.projectChanged()
    }
    
}

extension ProjectViewController: ScopeDelegate{
    
    func scopeChanged() {
        updateScopeSection()
    }
    
}

extension ProjectViewController: FilterDelegate{
    
    func filterChanged() {
        updateScopeSection()
        updateFilterItem()
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
        block.addArrangedSubview(InfoHeader("projectScopesInfoHeader".localize()))
        block.addArrangedSubview(InfoText("projectScopesInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "seal", text: "projectSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "checkmark.seal", text: "projectCheckmarkSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "xmark.seal", text: "projectXmarkSealSymbolText".localize(), iconColor: .systemBlue))
    }
    
}




