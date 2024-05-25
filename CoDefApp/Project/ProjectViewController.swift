/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import E5Data
import E5IOSUI

class ProjectViewController: ScrollViewController {
    
    var project : ProjectData
    
    var delegate: ProjectDelegate? = nil
    
    var dataSection = ArrangedSectionView()
    var unitSection = UIView()
    var reportsSection = UIView()
    
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
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = ProjectPdfViewController(project: self.project)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if AppState.shared.standalone || !project.isOnServer {
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditProjectViewController(project: self.project)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            self.showDestructiveApprove(title: "delete".localize(), text: "deleteInfo".localize(), onApprove: {
                AppData.shared.removeProject(self.project)
                AppData.shared.save()
                self.delegate?.projectChanged()
                self.navigationController?.popViewController(animated: true)
            })
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
        setupUnitSection()
        contentView.addSubviewAtTop(reportsSection, topView: unitSection)
            .bottom(contentView.bottomAnchor)
        setupReportsSection()
    }
    
    func setupDataSection(){
        let nameLabel = LabeledText()
        nameLabel.setupView(labelText: "name".localizeWithColon(), text: project.displayName)
        dataSection.addArrangedSubview(nameLabel)
        
        let addressLabel = LabeledText()
        addressLabel.setupView(labelText: "address".localizeWithColon(), text: project.address)
        dataSection.addArrangedSubview(addressLabel)
        
        let weatherStationLabel = LabeledText()
        weatherStationLabel.setupView(labelText: "weatherStation".localizeWithColon(), text: project.weatherStation)
        dataSection.addArrangedSubview(weatherStationLabel)
        
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
        unitSection.addSubviewAtTop(headerLabel, insets: narrowInsets)
        var lastView: UIView = headerLabel
        for unit in project.units{
            let sectionLine = getUnitSectionLine(unit: unit)
            unitSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: unitSection.leadingAnchor, trailing: unitSection.trailingAnchor, insets: narrowInsets)
            lastView = sectionLine
        }
        let addUnitButton = TextButton(text: "newUnit".localize())
        addUnitButton.addAction(UIAction(){ (action) in
            let unit = UnitData(project: self.project)
            let controller = EditUnitViewController(unit: unit)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        unitSection.addSubviewAtTopCentered(addUnitButton, topView: lastView, insets: doubleInsets)
            .bottom(unitSection.bottomAnchor, inset: -2*defaultInset)
        
    }
    
    func setupReportsSection(){
        let headerLabel = UILabel(header: "dailyReports".localizeWithColon())
        reportsSection.addSubviewAtTop(headerLabel, insets: narrowInsets)
        
        let sectionLine = SectionLine(name: "recentReports".localize(), action: UIAction(){action in
            let controller = ReportsListViewController(project: self.project)
            self.navigationController?.pushViewController(controller, animated: true)
        })
        reportsSection.addSubviewWithAnchors(sectionLine, top: headerLabel.bottomAnchor, leading: reportsSection.leadingAnchor, trailing: reportsSection.trailingAnchor, insets: narrowInsets)
        
        let addDailyReportButton = TextButton(text: "newDailyReport".localize())
        addDailyReportButton.addAction(UIAction(){ (action) in
            let dailyReport = DailyReport(project: self.project)
            let controller = EditDailyReportViewController(report: dailyReport)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }, for: .touchDown)
        reportsSection.addSubviewAtTopCentered(addDailyReportButton, topView: sectionLine, insets: doubleInsets)
            .bottom(reportsSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func getUnitSectionLine(unit: UnitData) -> UIView{
        let line = SectionLine(name: unit.displayName, action: UIAction(){action in
            let controller = UnitViewController(unit: unit)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        })
        let inFilter = unit.isInFilter()
        let filterIcon = IconView(icon: inFilter ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.xmark", tintColor: inFilter ? .gray : .lightGray)
        line.addSubviewAtLeft(filterIcon, leadingView: line.label, insets: UIEdgeInsets(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: 0))
        return line
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

extension ProjectViewController: DailyReportDelegate{
    
    func dailyReportChanged() {
    }
    
}

class ProjectInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "doc.text", text: "projectReportSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "projectEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "projectDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("projectUnitsInfoHeader".localize()))
        block.addArrangedSubview(InfoText("projectUnitsInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "person.crop.circle.badge.checkmark", text: "filterCheckmarkSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "person.crop.circle.badge.xmark", text: "filterXmarkSymbolText".localize(), iconColor: .lightGray))
    }
    
}




