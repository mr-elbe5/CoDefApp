/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import UniformTypeIdentifiers

class MainViewController: ScrollViewController {
    
    var projectSection = UIView()
    var userSection = UIView()
    
    override func loadView() {
        title = "overview".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "companyFilter".localize(), image: UIImage(systemName: "person.fill.viewfinder"), primaryAction: UIAction(){ action in
            let controller = CompanyFilterViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "defectFilter".localize(), image: UIImage(systemName: "ellipsis.viewfinder"), primaryAction: UIAction(){ action in
            let controller = DefectFilterViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
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
                self.showAccept(title: "restoreBackup".localize(), text: "restoreHint".localize()){
                    self.restore()
                }
            }
            let zipItem = UIBarButtonItem(title: "".localize(), image: UIImage(systemName: "doc.zipper"))
            zipItem.menu = UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [backupAction, restoreAction])
            zipItem.primaryAction = nil
            items.append(zipItem)
        }
        items.append(UIBarButtonItem(title: "settings".localize(), image: UIImage(systemName: "gear"), primaryAction: UIAction(){ action in
            let controller = SettingsViewController()
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
        setupProjectSection()
        contentView.addSubviewAtTop(userSection, topView: projectSection)
            .bottom(contentView.bottomAnchor)
        if AppState.shared.currentUser.hasSystemRight{
            setupUserSection()
        }
    }
    
    func setupProjectSection(){
        let headerLabel = UILabel(header: "projects".localizeWithColon())
        projectSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        var lastView: UIView = headerLabel
        
        for project in AppData.shared.projects{
            let sectionLine = SectionLine(name: project.name, action: UIAction(){ action in
                let controller = ProjectViewController(project: project)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
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
    
    func updateProjectSection(){
        projectSection.removeAllSubviews()
        setupProjectSection()
    }
    
    func setupUserSection(){
        let headerLabel = UILabel(header: "companies".localizeWithColon())
        userSection.addSubviewAtTop(headerLabel, insets: verticalInsets)
        var lastView: UIView = headerLabel
        
        for company in AppData.shared.companies{
            let sectionLine = SectionLine(name: company.name, action: UIAction(){ action in
                let controller = CompanyViewController(company: company)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            })
            userSection.addSubviewWithAnchors(sectionLine, top: lastView.bottomAnchor, leading: userSection.leadingAnchor, trailing: userSection.trailingAnchor, insets: verticalInsets)
            lastView = sectionLine
        }
        let addUserButton = TextButton(text: "newCompany".localize(), withBorder: true)
        addUserButton.addAction(UIAction(){ action in
            self.openAddUser()
        }, for: .touchDown)
        userSection.addSubviewAtTopCentered(addUserButton, topView: lastView, insets: doubleInsets)
            .bottom(userSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func updateUserSection(){
        userSection.removeAllSubviews()
        setupUserSection()
    }
    
    func openAddProject(){
        let controller = EditProjectViewController(project: ProjectData())
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func openAddUser(){
        let controller = EditCompanyViewController(company: CompanyData())
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func backup(){
        let fileName = "issuetracker_backup_\(Date().shortFileDate()).zip"
        if let url = FileController.createBackupFile(name: fileName){
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

extension MainViewController: ServerDelegate{
    
    func loginChanged() {
        
    }
    
    func synchronized() {
        
    }
    
}

extension MainViewController: ProjectDelegate{
    
    func projectChanged() {
        updateProjectSection()
    }
    
}

extension MainViewController: CompanyDelegate{
    
    func companyChanged() {
        updateUserSection()
    }
    
}

extension MainViewController: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        if FileController.unzipBackupFile(zipFileURL: url){
            if FileController.restoreBackup(){
                showDone(title: "success".localize(), text: "restoreDone".localize()){
                    self.updateProjectSection()
                    self.updateUserSection()
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
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("mainUsersInfoHeader".localize()))
        block.addArrangedSubview(InfoText("mainUsersInfoText".localize()))
    }
    
}
