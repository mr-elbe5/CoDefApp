/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

protocol ServerDelegate{
    func synchronized()
}

class ServerViewController: ScrollViewController {
    
    var connectionLabel = LabeledText()
    var openLoginButton = TextButton(text: "openLogin".localize(), withBorder: false)
    
    var newElementsField = LabeledText()
    
    var uploadButton = TextButton(text: "synchronizeToServer".localize(), withBorder: true)
    
    var uploadedProjectsField = LabeledText()
    var uploadedUnitsField = LabeledText()
    var uploadedDefectsField = LabeledText()
    var uploadedStatusChangesField = LabeledText()
    var uploadedImagesField = LabeledText()
    var uploadErrorsField = LabeledText()
    
    var uploadProgressSlider = UISlider()
    
    var downloadButton = TextButton(text: "synchronizeFromServer".localize(), withBorder: true)
    
    var downloadedCompaniesField = LabeledText()
    var downloadedProjectsField = LabeledText()
    var downloadedUnitsField = LabeledText()
    var downloadedDefectsField = LabeledText()
    var downloadedStatusChangesField = LabeledText()
    var downloadedImagesField = LabeledText()
    var downloadErrorsField = LabeledText()
    
    var downloadProgressSlider = UISlider()
    
    var delegate: ServerDelegate? = nil
    
    override func loadView() {
        title = "server".localize()
        super.loadView()
        modalPresentationStyle = .fullScreen
        AppState.shared.setUnsynchronizedElementCount()
        AppState.shared.delegate = self
    }
    
    override func setupContentView() {
        
        let item = UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = ServerInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        navigationItem.rightBarButtonItem = item
        
        let syncSection = SectionView()
        syncSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(syncSection)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        
        let header = UILabel(header: "synchronizeServer".localize())
        syncSection.addSubviewAtTopCentered(header)
        
        connectionLabel.setupView(labelText: "connectionState".localizeWithColon(), text: AppState.shared.currentUser.isLoggedIn ? "connected".localize() : "disconnected".localize(), inline: true)
        syncSection.addSubviewAtTop(connectionLabel, topView: header, insets: Insets.horizontalInsets)
        
        openLoginButton.addAction(UIAction(){ action in
            let loginController = LoginViewController()
            loginController.delegate = self
            self.navigationController?.pushViewController(loginController, animated: true)
        }, for: .touchDown)
        syncSection.addSubviewAtTop(openLoginButton, topView: connectionLabel)
        
        newElementsField.setupView(labelText: "newElements".localizeWithColon(), text: String(AppState.shared.unsynchronizedElementsCount), inline: true)
        syncSection.addSubviewAtTop(newElementsField, topView: openLoginButton, insets: Insets.horizontalInsets)
        
        uploadButton.setTitleColor(.systemGray, for: .disabled)
        uploadButton.addAction(UIAction(){ action in
            self.uploadProgressSlider.value = 0
            self.uploadProgressSlider.maximumValue = Float(AppState.shared.unsynchronizedElementsCount)
            self.upload()
        }, for: .touchDown)
        syncSection.addSubviewAtTopCentered(uploadButton, topView: newElementsField)
        uploadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        var label = UILabel(header: "uploaded".localize())
        syncSection.addSubviewAtTop(label, topView: uploadButton)
        
        uploadedProjectsField.setupView(labelText: "projects".localizeWithColon(), text: String(AppState.shared.uploadedProjects), inline: true)
        syncSection.addSubviewAtTop(uploadedProjectsField, topView: label, insets: Insets.horizontalInsets)
        
        uploadedUnitsField.setupView(labelText: "units".localizeWithColon(), text: String(AppState.shared.uploadedUnits), inline: true)
        syncSection.addSubviewAtTop(uploadedUnitsField, topView: uploadedProjectsField, insets: Insets.horizontalInsets)
        
        uploadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(AppState.shared.uploadedDefects), inline: true)
        syncSection.addSubviewAtTop(uploadedDefectsField, topView: uploadedUnitsField, insets: Insets.horizontalInsets)
        
        uploadedStatusChangesField.setupView(labelText: "statusChanges".localizeWithColon(), text: String(AppState.shared.uploadedStatusChanges), inline: true)
        syncSection.addSubviewAtTop(uploadedStatusChangesField, topView: uploadedDefectsField, insets: Insets.horizontalInsets)
        
        uploadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(AppState.shared.uploadedImages), inline: true)
        syncSection.addSubviewAtTop(uploadedImagesField, topView: uploadedStatusChangesField, insets: Insets.horizontalInsets)
        
        uploadErrorsField.setupView(labelText: "errors".localizeWithColon(), text: String(AppState.shared.uploadErrors), inline: true)
        syncSection.addSubviewAtTop(uploadErrorsField, topView: uploadedImagesField, insets: Insets.horizontalInsets)
        
        uploadProgressSlider.minimumValue = 0
        uploadProgressSlider.maximumValue = 1
        uploadProgressSlider.value = 0
        syncSection.addSubviewAtTop(uploadProgressSlider, topView: uploadErrorsField)
        
        label = UILabel(header: "downloaded".localize())
        syncSection.addSubviewAtTop(label, topView: uploadProgressSlider)
        
        downloadButton.setTitleColor(.systemGray, for: .disabled)
        downloadButton.addAction(UIAction(){ action in
            self.downloadProgressSlider.value = 0
            self.download()
        }, for: .touchDown)
        syncSection.addSubviewAtTopCentered(downloadButton, topView: label)
        downloadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        downloadedCompaniesField.setupView(labelText: "companies".localizeWithColon(), text: String(AppState.shared.downloadedCompanies), inline: true)
        syncSection.addSubviewAtTop(downloadedCompaniesField, topView: downloadButton, insets: Insets.horizontalInsets)
        
        downloadedProjectsField.setupView(labelText: "projects".localizeWithColon(), text: String(AppState.shared.downloadedProjects), inline: true)
        syncSection.addSubviewAtTop(downloadedProjectsField, topView: downloadedCompaniesField, insets: Insets.horizontalInsets)
        
        downloadedUnitsField.setupView(labelText: "units".localizeWithColon(), text: String(AppState.shared.downloadedUnits), inline: true)
        syncSection.addSubviewAtTop(downloadedUnitsField, topView: downloadedProjectsField, insets: Insets.horizontalInsets)
        
        downloadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(AppState.shared.downloadedDefects), inline: true)
        syncSection.addSubviewAtTop(downloadedDefectsField, topView: downloadedUnitsField, insets: Insets.horizontalInsets)
        
        downloadedStatusChangesField.setupView(labelText: "statusChanges".localizeWithColon(), text: String(AppState.shared.downloadedStatusChanges), inline: true)
        syncSection.addSubviewAtTop(downloadedStatusChangesField, topView: downloadedDefectsField, insets: Insets.horizontalInsets)
        
        downloadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(AppState.shared.downloadedImages), inline: true)
        syncSection.addSubviewAtTop(downloadedImagesField, topView: downloadedStatusChangesField, insets: Insets.horizontalInsets)
        
        downloadErrorsField.setupView(labelText: "errors".localizeWithColon(), text: String(AppState.shared.downloadErrors), inline: true)
        syncSection.addSubviewAtTop(downloadErrorsField, topView: downloadedImagesField, insets: Insets.horizontalInsets)
        
        downloadProgressSlider.minimumValue = 0
        downloadProgressSlider.maximumValue = 1
        downloadProgressSlider.value = 0
        syncSection.addSubviewAtTop(downloadProgressSlider, topView: downloadErrorsField)
            .bottom(syncSection.bottomAnchor, inset: -defaultInset)
        
        loginChanged()
    }
    
    func upload(){
        AppState.shared.resetUpload()
        uploadStateChanged()
        Task{
            await AppData.shared.upload()
        }
    }
    
    func download(){
        AppState.shared.resetDownload()
        downloadStateChanged()
        Task{
            await AppData.shared.loadServerData()
            await MainActor.run{
                downloadProgressSlider.value = 1
                if let mainController = self.navigationController?.previousViewController as? MainViewController{
                    mainController.updateProjectSection()
                    mainController.updateUserSection()
                }
            }
        }
    }
    
}

extension ServerViewController: LoginDelegate{
    
    func loginChanged() {
        connectionLabel.text = AppState.shared.currentUser.isLoggedIn ? "connected".localize() : "disconnected".localize()
        uploadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        downloadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
    }
    
}

extension ServerViewController: AppStateDelegate{
    
    func uploadStateChanged() {
        newElementsField.text = String(AppState.shared.unsynchronizedElementsCount)
        uploadedProjectsField.text = String(AppState.shared.uploadedProjects)
        uploadedUnitsField.text = String(AppState.shared.uploadedUnits)
        uploadedDefectsField.text = String(AppState.shared.uploadedDefects)
        uploadedStatusChangesField.text = String(AppState.shared.uploadedStatusChanges)
        uploadedImagesField.text = String(AppState.shared.uploadedImages)
        uploadErrorsField.text = String(AppState.shared.uploadErrors)
        if AppState.shared.uploadedItems != 0{
            uploadProgressSlider.value = uploadProgressSlider.maximumValue / Float(AppState.shared.uploadedItems)
        }
    }
    
    func downloadStateChanged() {
        downloadedCompaniesField.text = String(AppState.shared.downloadedCompanies)
        downloadedProjectsField.text = String(AppState.shared.downloadedProjects)
        downloadedUnitsField.text = String(AppState.shared.downloadedUnits)
        downloadedDefectsField.text = String(AppState.shared.downloadedDefects)
        downloadedStatusChangesField.text = String(AppState.shared.downloadedStatusChanges)
        downloadedImagesField.text = String(AppState.shared.downloadedImages)
        downloadErrorsField.text = String(AppState.shared.downloadErrors)
    }
    
    
}

class ServerInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = InfoBlock()
        stackView.addArrangedSubview(block)
        block.stackView.addArrangedSubview(InfoHeader("serverInfoHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("serverInfoText".localize()))
    }
    
}

