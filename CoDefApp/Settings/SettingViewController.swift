/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import StoreKit

protocol SettingsDelegate{
    func standaloneChanged()
}

class SettingsViewController: ScrollViewController {
    
    var standaloneSection = SectionView()
    var useServerSwitch = LabeledCheckbox()
    
    var settingsSection = SectionView()
    var usedateTimeSwitch = LabeledCheckbox()
    var useNotifiedSwitch = LabeledCheckbox()
    
    var cleanupSection = SectionView()
    
    var delegate: SettingsDelegate? = nil
    
    override func loadView() {
        title = "settings".localize()
        super.loadView()
        modalPresentationStyle = .fullScreen
        
        let item = UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = SettingsInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        navigationItem.rightBarButtonItem = item
        
    }
    
    override func setupContentView() {
        contentView.addSubviewAtTop(standaloneSection)
        setupStandaloneSection()
        contentView.addSubviewAtTop(settingsSection, topView: standaloneSection)
        setupSettingsSection()
        contentView.addSubviewAtTop(cleanupSection, topView: settingsSection)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        setupCleanupSection()
    }
    
    func setupStandaloneSection(){
        let label  = UILabel(header: "appMode".localize())
        standaloneSection.addSubviewAtTopCentered(label)
        let text  = UILabel(text: "appModeText".localize())
        standaloneSection.addSubviewAtTop(text, topView: label)
        standaloneSection.addSubviewAtTop(useServerSwitch, topView: text)
            .bottom(standaloneSection.bottomAnchor)
        useServerSwitch.setup(title: "useServer".localize(), index: -1, isOn: !AppState.shared.standalone)
        useServerSwitch.delegate = self
    }
    
    func setupSettingsSection(){
        let label  = UILabel(header: "settings".localize())
        settingsSection.addSubviewAtTopCentered(label)
        let text  = UILabel(text: "settingsText".localize())
        settingsSection.addSubviewAtTop(text, topView: label)
        settingsSection.addSubviewAtTop(usedateTimeSwitch, topView: text)
        usedateTimeSwitch.setup(title: "useDateTime".localize(), index: -2, isOn: AppState.shared.useDateTime)
        usedateTimeSwitch.delegate = self
        settingsSection.addSubviewAtTop(useNotifiedSwitch, topView: usedateTimeSwitch)
            .bottom(settingsSection.bottomAnchor)
        useNotifiedSwitch.setup(title: "useNotified".localize(), index: -3, isOn: AppState.shared.useNotified)
        useNotifiedSwitch.delegate = self
    }
    
    func setupCleanupSection(){
        var label  = UILabel(header: "projects".localize() + "/" + "companies".localize())
        cleanupSection.addSubviewAtTopCentered(label)
        
        let deleteButton = TextButton(text: "deleteData".localize(), withBorder: true)
        deleteButton.addAction(UIAction(){ action in
            self.deleteData()
        }, for: .touchDown)
        cleanupSection.addSubviewAtTopCentered(deleteButton, topView: label)
        label  = UILabel(header: "images".localize())
        cleanupSection.addSubviewAtTopCentered(label, topView: deleteButton)
        
        let cleanupButton = TextButton(text: "cleanup".localize(), withBorder: true)
        cleanupButton.addAction(UIAction(){ action in
            self.cleanup()
        }, for: .touchDown)
        cleanupSection.addSubviewAtTopCentered(cleanupButton, topView: label)
            .bottom(cleanupSection.bottomAnchor, inset: -defaultInset)
    }
    
    func deleteData(){
        showApprove(text: "deleteDataHint".localize(), onApprove: {
            AppData.shared.deleteAllData()
            self.showDone(title: "success".localize(), text: "dataDeleted".localize())
            if let mainController = self.navigationController?.previousViewController as? MainViewController{
                mainController.updateProjectSection()
                mainController.updateCompanySection()
            }
        })
    }
    
    func cleanup(){
        let usedImageNames = AppData.shared.usedImageNames
        let count = FileController.cleanupFiles(usedNames: usedImageNames)
        showDone(title: "result".localize(), text: "filesDeleted".localizeWithColon() + " " + String(count))
    }
    
}

extension SettingsViewController: CheckboxDelegate{
    
    func checkboxIsSelected(index: Int, value: String) {
        if index == -1{
            AppState.shared.standalone = !self.useServerSwitch.isOn
            AppState.shared.save()
            self.delegate?.standaloneChanged()
        }
        else if index == -2{
            AppState.shared.useDateTime = usedateTimeSwitch.isOn
            AppState.shared.save()
        }
        else if index == -3{
            AppState.shared.useNotified = useNotifiedSwitch.isOn
            AppState.shared.save()
        }
    }
    
}

class SettingsInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = InfoBlock()
        stackView.addArrangedSubview(block)
        block.stackView.addArrangedSubview(InfoHeader("settingsInfoStandaloneHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("settingsInfoStandaloneText".localize()))
        stackView.addSpacer()
        block = InfoBlock()
        stackView.addArrangedSubview(block)
        block.stackView.addArrangedSubview(InfoHeader("settingsInfoCleanupHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("settingsInfoCleanupText".localize()))
    }
    
}
