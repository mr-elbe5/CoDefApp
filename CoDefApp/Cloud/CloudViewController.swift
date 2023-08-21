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
    
    var uploadedDefectsField = LabeledText()
    var uploadedImagesField = LabeledText()
    
    var uploadProgressSlider = UISlider()
    
    var downloadButton = IconTextButton(icon: "arrow.down.square", text: "download".localize(), withBorder: true)
    
    var downloadedDefectsField = LabeledText()
    var downloadedImagesField = LabeledText()
    
    var downloadProgressSlider = UISlider()
    
    var syncResult : SyncResult = SyncResult()
    
    var delegate: CloudDelegate? = nil
    
    override func loadView() {
        title = "server".localize()
        super.loadView()
        modalPresentationStyle = .fullScreen
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
        
        let connectionLabel = LabeledText()
        connectionLabel.setupView(labelText: "connectionState".localizeWithColon(), text: AppState.shared.currentUser.isLoggedIn ? "connected".localize() : "disconnected".localize(), inline: true)
        syncSection.addSubviewAtTop(connectionLabel)
        
        let header = UILabel(header: "synchronizeServer".localize())
        syncSection.addSubviewAtTopCentered(header, topView: connectionLabel)
        
        newElementsField.setupView(labelText: "newElements".localizeWithColon(), text: String(syncResult.newElementsCount), inline: true)
        syncSection.addSubviewAtTop(newElementsField, topView: header)
        
        uploadButton.setTitleColor(.systemGray, for: .disabled)
        uploadButton.addAction(UIAction(){ action in
            //todo
            //CloudSynchronizer.shared.synchronize(syncResult: self.syncResult)
        }, for: .touchDown)
        syncSection.addSubviewAtTopCentered(uploadButton, topView: newElementsField)
        uploadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        var label = UILabel(header: "uploaded".localize())
        syncSection.addSubviewAtTop(label, topView: uploadButton)
        
        uploadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(syncResult.defectsUploaded), inline: true)
        syncSection.addSubviewAtTop(uploadedDefectsField, topView: label)
        
        uploadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(syncResult.imagesUploaded), inline: true)
        syncSection.addSubviewAtTop(uploadedImagesField, topView: uploadedDefectsField)
        
        uploadProgressSlider.minimumValue = 0
        uploadProgressSlider.maximumValue = 100
        uploadProgressSlider.value = Float(syncResult.uploadProgress)
        syncSection.addSubviewAtTop(uploadProgressSlider, topView: uploadedImagesField)
        
        label = UILabel(header: "downloaded".localize())
        syncSection.addSubviewAtTop(label, topView: uploadProgressSlider)
        
        downloadButton.setTitleColor(.systemGray, for: .disabled)
        downloadButton.addAction(UIAction(){ action in
            //todo
            //CloudSynchronizer.shared.synchronize(syncResult: self.syncResult)
        }, for: .touchDown)
        syncSection.addSubviewAtTopCentered(downloadButton, topView: label)
        downloadButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        downloadedDefectsField.setupView(labelText: "defects".localizeWithColon(), text: String(syncResult.defectsLoaded), inline: true)
        syncSection.addSubviewAtTop(downloadedDefectsField, topView: downloadButton)
        
        downloadedImagesField.setupView(labelText: "images".localizeWithColon(), text: String(syncResult.imagesLoaded), inline: true)
        syncSection.addSubviewAtTop(downloadedImagesField, topView: downloadedDefectsField)
        
        downloadProgressSlider.minimumValue = 0
        downloadProgressSlider.maximumValue = 100
        downloadProgressSlider.value = Float(syncResult.downloadProgress)
        syncSection.addSubviewAtTop(downloadProgressSlider, topView: downloadedImagesField)
            .bottom(syncSection.bottomAnchor, inset: -defaultInset)
        
    }
    
    func upload(){
        Task{
            await AppData.shared.uploadNewItems(syncResult: syncResult)
        }
    }
    
    func download(){
        Task{
            await AppData.shared.loadProjects(syncResult: syncResult)
            await MainActor.run{
                syncResult.downloadProgress = 1.0
            }
        }
    }
    
}

extension CloudViewController: SyncResultDelegate{
    
    func uploadChanged() {
        
    }
    
    func downloadChanged() {
        
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

