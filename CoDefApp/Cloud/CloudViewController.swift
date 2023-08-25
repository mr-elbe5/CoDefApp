/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

protocol CloudDelegate{
    func synchronized()
}

class CloudViewController: ScrollViewController {
    
    var newElementsField = LabeledText()
    
    var uploadButton = IconTextButton(icon: "arrow.up.square", text: "upload".localize(), withBorder: true)
    
    var uploadedCompaniesField = LabeledText()
    var uploadedProjectsField = LabeledText()
    var uploadedUnitsField = LabeledText()
    var uploadedDefectsField = LabeledText()
    var uploadedStatusChangesField = LabeledText()
    var uploadedImagesField = LabeledText()
    var uploadErrorsField = LabeledText()
    
    var uploadProgressSlider = UISlider()
    
    var downloadButton = IconTextButton(icon: "arrow.down.square", text: "download".localize(), withBorder: true)
    
    var downloadedCompaniesField = LabeledText()
    var downloadedProjectsField = LabeledText()
    var downloadedUnitsField = LabeledText()
    var downloadedDefectsField = LabeledText()
    var downloadedStatusChangesField = LabeledText()
    var downloadedImagesField = LabeledText()
    var presentImagesField = LabeledText()
    var downloadErrorsField = LabeledText()
    
    var downloadProgressSlider = UISlider()
    
    var syncResult : SyncResult = SyncResult()
    
    var delegate: CloudDelegate? = nil
    
    override func loadView() {
        title = "server".localize()
        super.loadView()
        modalPresentationStyle = .fullScreen
        syncResult.setUnsynchronizedElementCount()
        syncResult.delegate = self
    }
    
    override func setupContentView() {
        
        let item = UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = CloudInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        navigationItem.rightBarButtonItem = item
        
        let syncSection = SectionView()
        syncSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(syncSection)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        
        let header = UILabel(header: "synchronizeServer".localize())
        syncSection.addSubviewAtTopCentered(header)
        
        let connectionLabel = LabeledText()
        connectionLabel.setupView(labelText: "connectionState".localizeWithColon(), text: AppState.shared.currentUser.isLoggedIn ? "connected".localize() : "disconnected".localize(), inline: true)
        syncSection.addSubviewAtTop(connectionLabel, topView: header, insets: Insets.horizontalInsets)
        
        newElementsField.setupView(labelText: "newElements".localizeWithColon(), text: String(syncResult.unsynchronizedElementsCount), inline: true)
        syncSection.addSubviewAtTop(newElementsField, topView: connectionLabel, insets: Insets.horizontalInsets)
        
        uploadButton.setTitleColor(.systemGray, for: .disabled)
        uploadButton.addAction(UIAction(){ action in
            self.uploadProgressSlider.value = 0
            self.uploadProgressSlider.maximumValue = Float(self.syncResult.unsynchronizedElementsCount)
            self.upload()
        }, for: .touchDown)
        syncSection.addSubviewAtTopCentered(uploadButton, topView: newElementsField)
        uploadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        var label = UILabel(header: "uploaded".localize())
        syncSection.addSubviewAtTop(label, topView: uploadButton)
        
        uploadedCompaniesField.setupView(labelText: "companies".localizeWithColon(), text: String(syncResult.uploadedCompanies), inline: true)
        syncSection.addSubviewAtTop(uploadedCompaniesField, topView: label, insets: Insets.horizontalInsets)
        
        uploadedProjectsField.setupView(labelText: "projects".localizeWithColon(), text: String(syncResult.uploadedProjects), inline: true)
        syncSection.addSubviewAtTop(uploadedProjectsField, topView: uploadedCompaniesField, insets: Insets.horizontalInsets)
        
        uploadedUnitsField.setupView(labelText: "units".localizeWithColon(), text: String(syncResult.uploadedUnits), inline: true)
        syncSection.addSubviewAtTop(uploadedUnitsField, topView: uploadedProjectsField, insets: Insets.horizontalInsets)
        
        uploadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(syncResult.uploadedDefects), inline: true)
        syncSection.addSubviewAtTop(uploadedDefectsField, topView: uploadedUnitsField, insets: Insets.horizontalInsets)
        
        uploadedStatusChangesField.setupView(labelText: "statusChanges".localizeWithColon(), text: String(syncResult.uploadedStatusChanges), inline: true)
        syncSection.addSubviewAtTop(uploadedStatusChangesField, topView: uploadedDefectsField, insets: Insets.horizontalInsets)
        
        uploadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(syncResult.uploadedImages), inline: true)
        syncSection.addSubviewAtTop(uploadedImagesField, topView: uploadedStatusChangesField, insets: Insets.horizontalInsets)
        
        uploadErrorsField.setupView(labelText: "errors".localizeWithColon(), text: String(syncResult.uploadErrors), inline: true)
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
        
        downloadedCompaniesField.setupView(labelText: "companies".localizeWithColon(), text: String(syncResult.loadedCompanies), inline: true)
        syncSection.addSubviewAtTop(downloadedCompaniesField, topView: downloadButton, insets: Insets.horizontalInsets)
        
        downloadedProjectsField.setupView(labelText: "projects".localizeWithColon(), text: String(syncResult.loadedProjects), inline: true)
        syncSection.addSubviewAtTop(downloadedProjectsField, topView: downloadedCompaniesField, insets: Insets.horizontalInsets)
        
        downloadedUnitsField.setupView(labelText: "units".localizeWithColon(), text: String(syncResult.loadedUnits), inline: true)
        syncSection.addSubviewAtTop(downloadedUnitsField, topView: downloadedProjectsField, insets: Insets.horizontalInsets)
        
        downloadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(syncResult.loadedDefects), inline: true)
        syncSection.addSubviewAtTop(downloadedDefectsField, topView: downloadedUnitsField, insets: Insets.horizontalInsets)
        
        downloadedStatusChangesField.setupView(labelText: "statusChanges".localizeWithColon(), text: String(syncResult.loadedStatusChanges), inline: true)
        syncSection.addSubviewAtTop(downloadedStatusChangesField, topView: downloadedDefectsField, insets: Insets.horizontalInsets)
        
        downloadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(syncResult.loadedImages), inline: true)
        syncSection.addSubviewAtTop(downloadedImagesField, topView: downloadedStatusChangesField, insets: Insets.horizontalInsets)
        
        presentImagesField.setupView(labelText: "presentImages".localizeWithColon(), text: String(syncResult.presentImages), inline: true)
        syncSection.addSubviewAtTop(presentImagesField, topView: downloadedImagesField, insets: Insets.horizontalInsets)
        
        downloadErrorsField.setupView(labelText: "errors".localizeWithColon(), text: String(syncResult.downloadErrors), inline: true)
        syncSection.addSubviewAtTop(downloadErrorsField, topView: presentImagesField, insets: Insets.horizontalInsets)
        
        downloadProgressSlider.minimumValue = 0
        downloadProgressSlider.maximumValue = 1
        downloadProgressSlider.value = 0
        syncSection.addSubviewAtTop(downloadProgressSlider, topView: downloadErrorsField)
            .bottom(syncSection.bottomAnchor, inset: -defaultInset)
        
    }
    
    func upload(){
        syncResult.resetUpload()
        updateUploadView()
        Task{
            await AppData.shared.uploadNewItems(syncResult: syncResult)
        }
    }
    
    func download(){
        syncResult.resetDownload()
        updateDownloadView()
        Task{
            await AppData.shared.loadServerData(syncResult: syncResult)
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

extension CloudViewController: SyncResultDelegate{
    
    func updateUploadView() {
        newElementsField.text = String(syncResult.unsynchronizedElementsCount)
        uploadedCompaniesField.text = String(syncResult.uploadedCompanies)
        uploadedProjectsField.text = String(syncResult.uploadedProjects)
        uploadedUnitsField.text = String(syncResult.uploadedUnits)
        uploadedDefectsField.text = String(syncResult.uploadedDefects)
        uploadedStatusChangesField.text = String(syncResult.uploadedStatusChanges)
        uploadedImagesField.text = String(syncResult.uploadedImages)
        uploadErrorsField.text = String(syncResult.uploadErrors)
        if syncResult.uploadedItems != 0{
            uploadProgressSlider.value = uploadProgressSlider.maximumValue / Float(syncResult.uploadedItems)
        }
    }
    
    func updateDownloadView() {
        downloadedCompaniesField.text = String(syncResult.loadedCompanies)
        downloadedProjectsField.text = String(syncResult.loadedProjects)
        downloadedUnitsField.text = String(syncResult.loadedUnits)
        downloadedDefectsField.text = String(syncResult.loadedDefects)
        downloadedStatusChangesField.text = String(syncResult.loadedStatusChanges)
        downloadedImagesField.text = String(syncResult.loadedImages)
        presentImagesField.text = String(syncResult.presentImages)
        downloadErrorsField.text = String(syncResult.downloadErrors)
    }
    
    
}

class CloudInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = InfoBlock()
        stackView.addArrangedSubview(block)
        block.stackView.addArrangedSubview(InfoHeader("cloudInfoHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("cloudInfoText".localize()))
    }
    
}

