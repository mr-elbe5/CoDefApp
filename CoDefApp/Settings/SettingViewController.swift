/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import StoreKit
import E5Data
import E5IOSUI

protocol SettingsDelegate{
    func standaloneChanged()
}

class SettingsViewController: ScrollViewController {
    
    var standaloneSection = SectionView()
    var useServerSwitch = LabeledCheckbox()
    
    var settingsSection = SectionView()
    var usedateTimeSwitch = LabeledCheckbox()
    var useNotifiedSwitch = LabeledCheckbox()
    
    var countryField = LabeledTextInput()
    var timeZoneField = LabeledTextInput()
    var meteoStatField = LabeledTextInput()
    
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
        Log.debug("controller: \(AppData.shared.serverSettings.country)")
        let label  = UILabel(header: "settings".localize())
        settingsSection.addSubviewAtTopCentered(label)
        let text  = UILabel(text: "settingsText".localize())
        settingsSection.addSubviewAtTop(text, topView: label)
        settingsSection.addSubviewAtTop(usedateTimeSwitch, topView: text)
        usedateTimeSwitch.setup(title: "useDateTime".localize(), index: -2, isOn: AppState.shared.useDateTime)
        usedateTimeSwitch.delegate = self
        settingsSection.addSubviewAtTop(useNotifiedSwitch, topView: usedateTimeSwitch)
            
        useNotifiedSwitch.setup(title: "useNotified".localize(), index: -3, isOn: AppState.shared.useNotified)
        useNotifiedSwitch.delegate = self
        
        countryField.setupView(labelText: "countryCode".localizeWithColon(), text: AppData.shared.serverSettings.country)
        settingsSection.addSubviewAtTop(countryField, topView: useNotifiedSwitch)
        
        timeZoneField.setupView(labelText: "timeZone".localizeWithColon(), text: AppData.shared.serverSettings.timeZoneName)
        settingsSection.addSubviewAtTop(timeZoneField, topView: countryField)
        
        meteoStatField.setupView(labelText: "meteoStatKey".localizeWithColon(), text: AppData.shared.serverSettings.meteoStatKey)
        settingsSection.addSubviewAtTop(meteoStatField, topView: timeZoneField)
        
        let saveButton = TextButton(text: "save".localize(), withBorder: true)
        saveButton.addAction(UIAction(){ action in
            self.saveSettings()
        }, for: .touchDown)
        settingsSection.addSubviewAtTopCentered(saveButton, topView: meteoStatField)
            .bottom(settingsSection.bottomAnchor, inset: -defaultInset)
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
    
    func saveSettings(){
        AppData.shared.serverSettings.country = countryField.text
        AppData.shared.serverSettings.timeZoneName = timeZoneField.text
        AppData.shared.serverSettings.meteoStatKey = meteoStatField.text
        AppData.shared.save()
    }
    
    func deleteData(){
        showApprove(title: "delete".localize(), text: "deleteDataHint".localize(), onApprove: {
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
        let count = FileManager.default.cleanupFiles(usedNames: usedImageNames)
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
