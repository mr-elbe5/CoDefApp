/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class ServerViewController: ScrollViewController {
    
    var connectionSection = SectionView()
    
    var connectionLabel = LabeledText()
    var openLoginButton = TextButton(text: "openLogin".localize(), withBorder: false)
    
    var uploadSection = SectionView()
    
    var newElementsField = LabeledText()
    
    var uploadButton = TextButton(text: "synchronizeToServer".localize(), withBorder: true)
    
    var uploadedCompaniesField = LabeledText()
    var uploadedProjectsField = LabeledText()
    var uploadedUnitsField = LabeledText()
    var uploadedDefectsField = LabeledText()
    var uploadedStatusChangesField = LabeledText()
    var uploadedImagesField = LabeledText()
    var uploadErrorsField = LabeledText()
    
    var uploadProgressSlider = UISlider()
    
    var downloadSection = SectionView()
    
    var downloadButton = TextButton(text: "synchronizeFromServer".localize(), withBorder: true)
    
    var downloadedCompaniesField = LabeledText()
    var downloadedProjectsField = LabeledText()
    var downloadedUnitsField = LabeledText()
    var downloadedDefectsField = LabeledText()
    var downloadedStatusChangesField = LabeledText()
    var downloadedImagesField = LabeledText()
    var downloadErrorsField = LabeledText()
    
    var downloadResult = IconTextButton(icon: "checkmark", text: "done".localize(), tintColor: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0))
    
    var cleanupSection = SectionView()
    
    override func loadView() {
        title = "server".localize()
        AppState.shared.resetUpload()
        AppState.shared.resetDownload()
        super.loadView()
        modalPresentationStyle = .fullScreen
        AppState.shared.delegate = self
    }
    
    override func setupContentView() {
        
        let item = UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = ServerInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        navigationItem.rightBarButtonItem = item
        
        connectionSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(connectionSection)
        setupConnectionSection()
        
        uploadSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(uploadSection, topView: connectionSection)
        setupUploadSection()
        
        downloadSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(downloadSection, topView: uploadSection)
        setupDownloadSection()
        
        cleanupSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(cleanupSection, topView: downloadSection)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        setupCleanupSection()
        
        checkLoginState()
    }
    
    func setupConnectionSection(){
        let header = UILabel(header: "synchronizeServer".localize())
        connectionSection.addSubviewAtTopCentered(header)
        
        connectionLabel.setupView(labelText: "connectionState".localizeWithColon(), text: "", inline: true)
        connectionSection.addSubviewAtTop(connectionLabel, topView: header, insets: Insets.horizontalInsets)
        
        openLoginButton.addAction(UIAction(){ action in
            let loginController = LoginViewController()
            loginController.delegate = self
            self.navigationController?.pushViewController(loginController, animated: true)
        }, for: .touchDown)
        connectionSection.addSubviewAtTop(openLoginButton, topView: connectionLabel)
            .bottom(connectionSection.bottomAnchor, inset: -Insets.defaultInset)
    }
    
    func setupUploadSection(){
        newElementsField.setupView(labelText: "newElements".localizeWithColon(), text: String(AppState.shared.newItemsCount), inline: true)
        uploadSection.addSubviewAtTop(newElementsField, insets: Insets.horizontalInsets)
        
        uploadButton.setTitleColor(.systemGray, for: .disabled)
        uploadButton.addAction(UIAction(){ action in
            self.upload()
        }, for: .touchDown)
        uploadSection.addSubviewAtTopCentered(uploadButton, topView: newElementsField)
        uploadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        let label = UILabel(header: "uploaded".localize())
        uploadSection.addSubviewAtTop(label, topView: uploadButton)
        
        uploadedCompaniesField.setupView(labelText: "companies".localizeWithColon(), text: String(AppState.shared.uploadedCompanies), inline: true)
        uploadSection.addSubviewAtTop(uploadedCompaniesField, topView: label, insets: Insets.horizontalInsets)
        
        uploadedProjectsField.setupView(labelText: "projects".localizeWithColon(), text: String(AppState.shared.uploadedProjects), inline: true)
        uploadSection.addSubviewAtTop(uploadedProjectsField, topView: uploadedCompaniesField, insets: Insets.horizontalInsets)
        
        uploadedUnitsField.setupView(labelText: "units".localizeWithColon(), text: String(AppState.shared.uploadedUnits), inline: true)
        uploadSection.addSubviewAtTop(uploadedUnitsField, topView: uploadedProjectsField, insets: Insets.horizontalInsets)
        
        uploadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(AppState.shared.uploadedDefects), inline: true)
        uploadSection.addSubviewAtTop(uploadedDefectsField, topView: uploadedUnitsField, insets: Insets.horizontalInsets)
        
        uploadedStatusChangesField.setupView(labelText: "statusChanges".localizeWithColon(), text: String(AppState.shared.uploadedStatusChanges), inline: true)
        uploadSection.addSubviewAtTop(uploadedStatusChangesField, topView: uploadedDefectsField, insets: Insets.horizontalInsets)
        
        uploadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(AppState.shared.uploadedImages), inline: true)
        uploadSection.addSubviewAtTop(uploadedImagesField, topView: uploadedStatusChangesField, insets: Insets.horizontalInsets)
        
        uploadErrorsField.setupView(labelText: "errors".localizeWithColon(), text: String(AppState.shared.uploadErrors), inline: true)
        uploadSection.addSubviewAtTop(uploadErrorsField, topView: uploadedImagesField, insets: Insets.horizontalInsets)
        
        uploadProgressSlider.minimumValue = 0
        uploadProgressSlider.maximumValue = 1
        uploadProgressSlider.value = 0
        uploadSection.addSubviewAtTop(uploadProgressSlider, topView: uploadErrorsField)
            .bottom(uploadSection.bottomAnchor, inset: -Insets.defaultInset)
    }
    
    func setupDownloadSection(){
        let label = UILabel(header: "downloaded".localize())
        downloadSection.addSubviewAtTop(label)
        
        downloadButton.setTitleColor(.systemGray, for: .disabled)
        downloadButton.addAction(UIAction(){ action in
            self.download()
        }, for: .touchDown)
        downloadSection.addSubviewAtTopCentered(downloadButton, topView: label)
        downloadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        downloadedCompaniesField.setupView(labelText: "companies".localizeWithColon(), text: String(AppState.shared.downloadedCompanies), inline: true)
        downloadSection.addSubviewAtTop(downloadedCompaniesField, topView: downloadButton, insets: Insets.horizontalInsets)
        
        downloadedProjectsField.setupView(labelText: "projects".localizeWithColon(), text: String(AppState.shared.downloadedProjects), inline: true)
        downloadSection.addSubviewAtTop(downloadedProjectsField, topView: downloadedCompaniesField, insets: Insets.horizontalInsets)
        
        downloadedUnitsField.setupView(labelText: "units".localizeWithColon(), text: String(AppState.shared.downloadedUnits), inline: true)
        downloadSection.addSubviewAtTop(downloadedUnitsField, topView: downloadedProjectsField, insets: Insets.horizontalInsets)
        
        downloadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(AppState.shared.downloadedDefects), inline: true)
        downloadSection.addSubviewAtTop(downloadedDefectsField, topView: downloadedUnitsField, insets: Insets.horizontalInsets)
        
        downloadedStatusChangesField.setupView(labelText: "statusChanges".localizeWithColon(), text: String(AppState.shared.downloadedStatusChanges), inline: true)
        downloadSection.addSubviewAtTop(downloadedStatusChangesField, topView: downloadedDefectsField, insets: Insets.horizontalInsets)
        
        downloadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(AppState.shared.downloadedImages), inline: true)
        downloadSection.addSubviewAtTop(downloadedImagesField, topView: downloadedStatusChangesField, insets: Insets.horizontalInsets)
        
        downloadErrorsField.setupView(labelText: "errors".localizeWithColon(), text: String(AppState.shared.downloadErrors), inline: true)
        downloadSection.addSubviewAtTop(downloadErrorsField, topView: downloadedImagesField, insets: Insets.horizontalInsets)
        
        downloadResult.addAction(UIAction(){ action in
            self.downloadResult.isHidden = true
            AppState.shared.resetDownload()
            self.downloadStateChanged()
        }, for: .touchDown)
        downloadSection.addSubviewAtTopCentered(downloadResult, topView: downloadErrorsField, insets: Insets.defaultInsets)
            .bottom(downloadSection.bottomAnchor, inset: -defaultInset)
        downloadResult.isHidden = true
        
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
    
    func upload(){
        AppState.shared.resetUpload()
        uploadStateChanged()
        self.uploadProgressSlider.maximumValue = Float(AppState.shared.newItemsCount)
        Task{
            await AppData.shared.uploadToServer()
        }
    }
    
    func download(){
        AppState.shared.resetDownload()
        downloadStateChanged()
        Task{
            await AppData.shared.loadServerData()
            await MainActor.run{
                downloadResult.isHidden = false
                if let mainController = self.navigationController?.previousViewController as? MainViewController{
                    mainController.updateProjectSection()
                    mainController.updateCompanySection()
                }
            }
        }
    }
    
    func checkLoginState() {
        connectionLabel.text = AppState.shared.currentUser.isLoggedIn ? "connected".localize() + ": " + AppState.shared.currentUser.name : "disconnected".localize()
        uploadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        downloadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
    }
    
    func deleteData(){
        showApprove(text: "deleteDataHint".localize(), onApprove:{
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

extension ServerViewController: LoginDelegate{
    
    func loginChanged() {
        checkLoginState()
    }
    
}

extension ServerViewController: AppStateDelegate{
    
    func uploadStateChanged() {
        newElementsField.text = String(AppState.shared.newItemsCount)
        uploadedCompaniesField.text = String(AppState.shared.uploadedCompanies)
        uploadedProjectsField.text = String(AppState.shared.uploadedProjects)
        uploadedUnitsField.text = String(AppState.shared.uploadedUnits)
        uploadedDefectsField.text = String(AppState.shared.uploadedDefects)
        uploadedStatusChangesField.text = String(AppState.shared.uploadedStatusChanges)
        uploadedImagesField.text = String(AppState.shared.uploadedImages)
        uploadErrorsField.text = String(AppState.shared.uploadErrors)
        uploadProgressSlider.value = Float(AppState.shared.uploadedItems)
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
        block.stackView.addArrangedSubview(InfoHeader("serverUploadInfoHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("serverUploadInfoText".localize()))
        block.stackView.addArrangedSubview(InfoHeader("serverDownloadInfoHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("serverDownloadInfoText".localize()))
    }
    
}

