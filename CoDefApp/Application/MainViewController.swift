/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import UniformTypeIdentifiers

class MainViewController: ScrollViewController {
    
    var projectSection = UIView()
    var companySection = UIView()
    
    override func loadView() {
        title = "overview".localize()
        super.loadView()
        updateNavigationItems()
    }
    
    func updateNavigationItems() {
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        if !AppState.shared.standalone{
            items.append(UIBarButtonItem(title: "cloud".localize(), image: UIImage(systemName: "cloud"), primaryAction: UIAction(){ action in
                let controller = ServerViewController()
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        if AppState.shared.currentUser.hasSystemRight{
            let backupAction = UIAction(title: "createBackup".localize()){ action in
                self.backup()
            }
            let restoreAction = UIAction(title: "restoreBackup".localize()){ action in
                self.showAccept(title: "restoreBackup".localize(), text: "restoreHint".localize(), onAccept: {
                    self.restore()
                })
            }
            let zipItem = UIBarButtonItem(title: "".localize(), image: UIImage(systemName: "doc.zipper"))
            zipItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [backupAction, restoreAction])
            zipItem.primaryAction = nil
            items.append(zipItem)
        }
        items.append(UIBarButtonItem(title: "settings".localize(), image: UIImage(systemName: "gear"), primaryAction: UIAction(){ action in
            let controller = SettingsViewController()
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = MainInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(projectSection)
        contentView.addSubviewAtTop(companySection, topView: projectSection)
            .bottom(contentView.bottomAnchor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProjectSection()
        updateCompanySection()
    }
    
    func setupProjectSection(){
        let headerLabel = UILabel(header: "projects".localizeWithColon())
        projectSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        var lastView: UIView = headerLabel
        
        for project in AppData.shared.projects{
            let sectionLine = getProjectSectionLine(project: project)
            projectSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: projectSection.leadingAnchor, trailing: projectSection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        let addProjectButton = TextButton(text: "newProject".localize(), withBorder: true)
        addProjectButton.addAction(UIAction(){ action in
            self.openAddProject()
        }, for: .touchDown)
        projectSection.addSubviewAtTopCentered(addProjectButton, topView: lastView, insets: doubleInsets)
            .bottom(projectSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func getProjectSectionLine(project: ProjectData) -> UIView{
        let line = SectionLine(name: project.displayName, action: UIAction(){action in
            let controller = ProjectViewController(project: project)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        })
        let inFilter = project.isInFilter()
        let filterIcon = IconView(icon: project.isInFilter() ? "person.crop.circle.badge.checkmark" : "person.crop.circle.badge.xmark", tintColor: inFilter ? .gray : .lightGray)
        line.addSubviewAtLeft(filterIcon, leadingView: line.label, insets: UIEdgeInsets(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: 0))
        return line
    }
    
    func updateProjectSection(){
        projectSection.removeAllSubviews()
        setupProjectSection()
    }
    
    func setupCompanySection(){
        let headerLabel = UILabel(header: "companies".localizeWithColon())
        companySection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        var lastView: UIView = headerLabel
        
        for company in AppData.shared.companies{
            let sectionLine = getCompanySectionLine(company: company)
            companySection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: companySection.leadingAnchor, trailing: companySection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        let addCompanyButton = TextButton(text: "newCompany".localize(), withBorder: true)
        addCompanyButton.addAction(UIAction(){ action in
            self.openAddCompany()
        }, for: .touchDown)
        companySection.addSubviewAtTopCentered(addCompanyButton, topView: lastView, insets: doubleInsets)
        addCompanyButton.bottom(companySection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func getCompanySectionLine(company: CompanyData) -> UIView{
        let line = SectionLine(name: company.name, action: UIAction(){action in
            let controller = CompanyViewController(company: company)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        })
        let selectButton = AppState.shared.isInFilter(id: company.id) ? IconButton(icon: "checkmark.circle", tintColor: .systemBlue) : IconButton(icon: "xmark.circle", tintColor: .lightGray)
        selectButton.addAction(UIAction(){ action in
            if AppState.shared.isInFilter(id: company.id){
                AppState.shared.removeFromFilter(id: company.id)
                selectButton.setIcon(icon: "xmark.circle", tintColor: .lightGray)
            }
            else{
                AppState.shared.addToFilter(id: company.id)
                selectButton.setIcon(icon: "checkmark.circle", tintColor: .systemBlue)
            }
            self.updateProjectSection()
        }, for: .touchDown)
        line.addSubviewWithAnchors(selectButton, leading: line.label.trailingAnchor, insets: wideInsets).centerY(line.centerYAnchor)
        return line
    }
    
    func updateCompanySection(){
        companySection.removeAllSubviews()
        setupCompanySection()
    }
    
    func openAddProject(){
        let controller = EditProjectViewController(project: ProjectData())
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openAddCompany(){
        let controller = EditCompanyViewController(company: CompanyData())
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func backup(){
        let fileName = "codeftracker_backup_\(Date().shortFileDate()).zip"
        if let url = Backup.createBackupFile(name: fileName){
            var urls = [URL]()
            urls.append(url)
            let documentPickerController = UIDocumentPickerViewController(
                forExporting: urls)
            self.present(documentPickerController, animated: true, completion: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func restore(){
        let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
}

extension MainViewController: SettingsDelegate{
    
    func standaloneChanged() {
        updateNavigationItems()
        updateCompanySection()
    }
    
    
}

extension MainViewController: ProjectDelegate{
    
    func projectChanged() {
        updateProjectSection()
    }
    
}

extension MainViewController: CompanyDelegate{
    
    func companyChanged() {
        updateCompanySection()
    }
    
}

extension MainViewController: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        if Backup.unzipBackupFile(zipFileURL: url){
            if Backup.restoreBackup(){
                showDone(title: "success".localize(), text: "restoreDone".localize()){
                    self.updateProjectSection()
                    self.updateCompanySection()
                    return
                }
            }
        }
    }
    
}

class MainInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("mainInfoHeader".localize()))
        block.addArrangedSubview(InfoText("mainInfoGeneral".localize()))
        block.addSpacer()
        block.addArrangedSubview(InfoHeader("mainInfoStructureHeader".localize()))
        block.addArrangedSubview(InfoText("mainInfoStructureText".localize()))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "cloud", text: "cloudSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "doc.zipper", text: "backupSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "gear", text: "settingsSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("mainProjectsInfoHeader".localize()))
        block.addArrangedSubview(InfoText("mainProjectsInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "person.crop.circle.badge.checkmark", text: "filterCheckmarkSymbolText".localize(), iconColor: .gray))
        block.addArrangedSubview(IconInfoText(icon: "person.crop.circle.badge.xmark", text: "filterXmarkSymbolText".localize(), iconColor: .lightGray))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("mainCompaniesInfoHeader".localize()))
        block.addArrangedSubview(InfoText("mainCompaniesInfoText".localize()))
        block.addArrangedSubview(IconInfoText(icon: "checkmark.circle", text: "companyCheckmarkSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "xmark.circle", text: "companyXmarkSymbolText".localize(), iconColor: .lightGray))
    }
    
}
