/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class UnitViewController: ScrollViewController {
    
    var unit: UnitData
    
    var delegate: UnitDelegate? = nil
    
    var dataSection = ArrangedSectionView()
    var issueSection = UIView()
    
    var filterItem: UIBarButtonItem? = nil
    
    init(unit: UnitData){
        self.unit = unit
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "unit".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        if let project = unit.project{
            filterItem = UIBarButtonItem(title: "filter".localize(), image: UIImage(systemName: project.filter.active ? "checkmark.seal" : "seal"), primaryAction: UIAction(){ action in
                let controller = FilterViewController(project: project)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            items.append(filterItem!)
        }
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = UnitPdfViewController(unit: self.unit)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if AppState.shared.currentUser.hasEditRight{
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditUnitViewController(unit: self.unit)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
                if let project = self.unit.project{
                    self.showDestructiveApprove(text: "deleteInfo".localize()){
                        project.removeUnit(self.unit)
                        project.changed()
                        project.saveData()
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.unitChanged()
                    }
                }
            }))
        }
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = UnitInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    func updateFilterItem(){
        if let project = self.unit.project{
            filterItem?.image =  UIImage(systemName: project.filter.active ? "checkmark.seal" : "seal")
        }
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(dataSection)
        setupDataSection()
        contentView.addSubviewAtTop(issueSection, topView: dataSection)
            .bottom(contentView.bottomAnchor)
        setupIssueSection()
    }
    
    func setupDataSection() {
        let nameView = LabeledText()
        nameView.setupView(labelText: "name".localizeWithColon(), text: unit.name)
        dataSection.addArrangedSubview(nameView)
        
        let descriptionView = LabeledText()
        descriptionView.setupView(labelText: "description".localizeWithColon(), text: unit.description)
        dataSection.addArrangedSubview(descriptionView)
        
        let approveDateView = LabeledText()
        approveDateView.setupView(labelText: "approveDate".localizeWithColon(), text: unit.approveDate?.dateString() ?? "")
        dataSection.addArrangedSubview(approveDateView)
    }
    
    func setupIssueSection(){
        let headerLabel = UILabel(header: "defects".localizeWithColon())
        issueSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        
        let addIssueButton = TextButton(text: "newDefect".localize())
        addIssueButton.addAction(UIAction(){ action in
            if !self.unit.projectCompanies.isEmpty{
                let controller = CreateDefectViewController(unit: self.unit)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                self.showError("noUsersError")
            }
        }, for: .touchDown)
        issueSection.addSubviewCentered(addIssueButton, centerX: issueSection.centerXAnchor, centerY: headerLabel.centerYAnchor)
        
        var lastView: UIView = addIssueButton
        let filteredIssues = unit.filteredDefects
        let filterActive = unit.isFilterActive
        
        for defect in unit.defects{
            let sectionLine = FilteredSectionLine(name: defect.name, filtered: filterActive, enabled: filteredIssues.contains(defect), action: UIAction(){ (action) in
                let controller = DefectViewController(defect: defect)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            issueSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: issueSection.leadingAnchor, trailing: issueSection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        
        if let plan = unit.plan{
            let planView = UnitPlanView(plan: plan.getImage())
            for defect in filteredIssues{
                if defect.position != .zero{
                    let marker = planView.addMarker(defect: defect)
                    marker.addAction(UIAction(){ action in
                        let controller = DefectViewController(defect: defect)
                        controller.delegate = self
                        self.navigationController?.pushViewController(controller, animated: true)
                    }, for: .touchDown)
                }
            }
            issueSection.addSubviewAtTop(planView, topView: lastView, insets: verticalInsets)
            lastView = planView
        }
        
        lastView.bottom(issueSection.bottomAnchor, inset: -defaultInset)
    }
    
    func updateDataSection(){
        dataSection.removeAllArrangedSubviews()
        setupDataSection()
    }
    
    func updateIssueSection(){
        issueSection.removeAllSubviews()
        setupIssueSection()
    }
    
}

extension UnitViewController: UnitDelegate{
    
    func unitChanged() {
        updateDataSection()
        delegate?.unitChanged()
    }
    
}

extension UnitViewController: DefectDelegate{
    
    func defectChanged() {
        updateIssueSection()
    }
    
}

extension UnitViewController: FilterDelegate{
    
    func filterChanged() {
        updateIssueSection()
        updateFilterItem()
    }
    
}

class UnitInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "unitEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "doc.text", text: "unitReportSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "unitDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("unitPlanInfoHeader".localize()))
        block.addArrangedSubview(InfoText("unitPlanInfoText".localize()))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("unitDefectsHeader".localize()))
        block.addArrangedSubview(InfoText("unitDefectsInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "seal", text: "unitSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "checkmark.seal", text: "unitCheckmarkSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "xmark.seal", text: "unitXmarkSealSymbolText".localize(), iconColor: .systemBlue))
    }
    
}
