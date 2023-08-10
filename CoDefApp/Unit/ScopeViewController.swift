/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class ScopeViewController: ScrollViewController {
    
    var scope: ScopeData
    
    var delegate: ScopeDelegate? = nil
    
    var dataSection = ArrangedSectionView()
    var issueSection = UIView()
    
    var filterItem: UIBarButtonItem? = nil
    
    init(scope: ScopeData){
        self.scope = scope
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "scope".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        if let project = scope.project{
            filterItem = UIBarButtonItem(title: "filter".localize(), image: UIImage(systemName: project.filter.active ? "checkmark.seal" : "seal"), primaryAction: UIAction(){ action in
                let controller = FilterViewController(project: project)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            items.append(filterItem!)
        }
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = ScopePdfViewController(scope: self.scope)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if CurrentUser.hasEditRight(for: scope){
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditScopeViewController(scope: self.scope)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
                if let project = self.scope.project{
                    self.showDestructiveApprove(text: "deleteInfo".localize()){
                        project.removeScope(self.scope)
                        project.changed()
                        project.saveData()
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.scopeChanged()
                    }
                }
            }))
        }
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = ScopeInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    func updateFilterItem(){
        if let project = self.scope.project{
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
        nameView.setupView(labelText: "name".localizeWithColon(), text: scope.name)
        dataSection.addArrangedSubview(nameView)
        
        let descriptionView = LabeledText()
        descriptionView.setupView(labelText: "description".localizeWithColon(), text: scope.description)
        dataSection.addArrangedSubview(descriptionView)
    }
    
    func setupIssueSection(){
        let headerLabel = UILabel(header: "issues".localizeWithColon())
        issueSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        
        let addIssueButton = TextButton(text: "newIssue".localize())
        addIssueButton.addAction(UIAction(){ action in
            if !self.scope.projectUsers.isEmpty{
                let controller = CreateIssueViewController(scope: self.scope)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                self.showError("noUsersError")
            }
        }, for: .touchDown)
        issueSection.addSubviewCentered(addIssueButton, centerX: issueSection.centerXAnchor, centerY: headerLabel.centerYAnchor)
        
        var lastView: UIView = addIssueButton
        let filteredIssues = scope.filteredIssues
        let filterActive = scope.isFilterActive
        
        for issue in scope.issues{
            let sectionLine = FilteredSectionLine(name: issue.name, filtered: filterActive, enabled: filteredIssues.contains(issue), action: UIAction(){ (action) in
                let controller = IssueViewController(issue: issue)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            issueSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: issueSection.leadingAnchor, trailing: issueSection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        
        if let plan = scope.plan{
            let planView = ScopePlanView(plan: plan.getImage())
            for issue in filteredIssues{
                if issue.position != .zero{
                    let marker = planView.addMarker(issue: issue)
                    marker.addAction(UIAction(){ action in
                        let controller = IssueViewController(issue: issue)
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

extension ScopeViewController: ScopeDelegate{
    
    func scopeChanged() {
        updateDataSection()
        delegate?.scopeChanged()
    }
    
}

extension ScopeViewController: IssueDelegate{
    
    func issueChanged() {
        updateIssueSection()
    }
    
}

extension ScopeViewController: FilterDelegate{
    
    func filterChanged() {
        updateIssueSection()
        updateFilterItem()
    }
    
}

class ScopeInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "scopeEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "doc.text", text: "scopeReportSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "scopeDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("scopePlanInfoHeader".localize()))
        block.addArrangedSubview(InfoText("scopePlanInfoText".localize()))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("scopeIssuesHeader".localize()))
        block.addArrangedSubview(InfoText("scopeIssuesInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "seal", text: "scopeSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "checkmark.seal", text: "scopeCheckmarkSealSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "xmark.seal", text: "scopeXmarkSealSymbolText".localize(), iconColor: .systemBlue))
    }
    
}
