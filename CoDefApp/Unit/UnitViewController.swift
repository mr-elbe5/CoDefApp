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
    var defectSection = UIView()
    
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
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = UnitPdfViewController(unit: self.unit)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if AppState.shared.standalone || !unit.isOnServer{
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditUnitViewController(unit: self.unit)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            if let project = self.unit.project{
                self.showDestructiveApprove(text: "deleteInfo".localize(), onApprove: {
                    project.removeUnit(self.unit)
                    project.changed()
                    project.saveData()
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.unitChanged()
                })
            }
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = UnitInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(dataSection)
        setupDataSection()
        contentView.addSubviewAtTop(defectSection, topView: dataSection)
            .bottom(contentView.bottomAnchor)
        setupDefectSection()
    }
    
    func setupDataSection() {
        let nameView = LabeledText()
        nameView.setupView(labelText: "name".localizeWithColon(), text: unit.displayName)
        dataSection.addArrangedSubview(nameView)
        
        let descriptionView = LabeledText()
        descriptionView.setupView(labelText: "description".localizeWithColon(), text: unit.description)
        dataSection.addArrangedSubview(descriptionView)
        
        let approveDateView = LabeledText()
        approveDateView.setupView(labelText: "approveDate".localizeWithColon(), text: unit.approveDate?.dateString() ?? "")
        dataSection.addArrangedSubview(approveDateView)
    }
    
    func setupDefectSection(){
        let headerLabel = UILabel(header: "defects".localizeWithColon())
        defectSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        
        let addDefectButton = TextButton(text: "newDefect".localize())
        addDefectButton.addAction(UIAction(){ action in
            if !self.unit.projectCompanies.isEmpty{
                let defect = DefectData(unit: self.unit)
                let controller = EditDefectViewController(defect: defect)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                self.showError("noUsersError")
            }
        }, for: .touchDown)
        defectSection.addSubviewWithAnchors(addDefectButton, top: headerLabel.bottomAnchor, insets: Insets.defaultInsets)
            .centerX(defectSection.centerXAnchor)
        
        var lastView: UIView = addDefectButton
        for defect in unit.defects{
            if defect.isInFilter(){
                let sectionLine = getDefectSectionLine(defect: defect)
                defectSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: defectSection.leadingAnchor, trailing: defectSection.trailingAnchor, insets: verticalInsets)
                lastView = sectionLine
            }
        }
        
        if let plan = unit.plan{
            let planView = UnitPlanView(plan: plan.getImage())
            for defect in unit.defects{
                if defect.isInFilter(), defect.position != .zero{
                    let marker = planView.addMarker(defect: defect)
                    marker.addAction(UIAction(){ action in
                        let controller = DefectViewController(defect: defect)
                        controller.delegate = self
                        self.navigationController?.pushViewController(controller, animated: true)
                    }, for: .touchDown)
                }
            }
            defectSection.addSubviewAtTop(planView, topView: lastView, insets: verticalInsets)
            lastView = planView
        }
        
        lastView.bottom(defectSection.bottomAnchor, inset: -defaultInset)
    }
    
    func getDefectSectionLine(defect: DefectData) -> UIView{
        let line = SectionLine(name: defect.displayName, action: UIAction(){action in
            let controller = DefectViewController(defect: defect)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        })
        return line
    }
    
    func updateDataSection(){
        dataSection.removeAllArrangedSubviews()
        setupDataSection()
    }
    
    func updateDefectSection(){
        defectSection.removeAllSubviews()
        setupDefectSection()
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
        updateDefectSection()
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
    }
    
}
