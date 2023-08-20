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
    
    var stateLabel = UILabel(text: "")
    
    var newElementsField = LabeledText()
    
    var syncButton = TextButton(text: "synchronize".localize(), withBorder: true)
    
    var uploadedIssuesField = LabeledText()
    var uploadedImagesField = LabeledText()
    
    var downloadedIssuesField = LabeledText()
    var downloadedImagesField = LabeledText()
    
    var progressSlider = UISlider()
    
    var syncResult : SyncResult = SyncResult()
    
    var delegate: CloudDelegate? = nil
    
    override func loadView() {
        title = "cloud".localize()
        super.loadView()
        modalPresentationStyle = .fullScreen
    }
    
    override func setupContentView() {
        
        let item = UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = CloudInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        navigationItem.rightBarButtonItem = item
        
        let syncSection = UIView()
        syncSection.setGrayRoundedBorders()
        contentView.addSubviewAtTop(syncSection)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        
        var label = UILabel(header: "connectionState".localize())
        syncSection.addSubviewAtTop(label)
        stateLabel.text = AppState.shared.currentUser.isLoggedIn ? "connected".localize() : "disconnected".localize()
        syncSection.addSubviewAtTop(stateLabel, topView: label)
        
        label = UILabel(header: "synchronize".localize())
        syncSection.addSubviewAtTopCentered(label, topView: stateLabel)
        
        newElementsField.setupView(labelText: "newElements".localize(), text: String(syncResult.newElementsCount))
        syncSection.addSubviewAtTop(newElementsField, topView: label)
        
        syncButton.setTitleColor(.systemGray, for: .disabled)
        syncButton.addAction(UIAction(){ action in
            //todo
            //CloudSynchronizer.shared.synchronize(syncResult: self.syncResult)
        }, for: .touchDown)
        syncSection.addSubviewAtTopCentered(syncButton, topView: newElementsField)
        syncButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        
        label = UILabel(header: "uploaded".localize())
        syncSection.addSubviewAtTop(label, topView: syncButton)
        
        uploadedIssuesField.setupView(labelText: "issues".localize(), text: String(syncResult.defectsUploaded))
        syncSection.addSubviewAtTop(uploadedIssuesField, topView: label)
        
        uploadedImagesField.setupView(labelText: "images".localize(), text: String(syncResult.imagesUploaded))
        syncSection.addSubviewAtTop(uploadedImagesField, topView: uploadedIssuesField)
        
        label = UILabel(header: "downloaded".localize())
        syncSection.addSubviewAtTop(label, topView: uploadedImagesField)
        
        downloadedIssuesField.setupView(labelText: "issues".localize(), text: String(syncResult.defectsLoaded))
        syncSection.addSubviewAtTop(downloadedIssuesField, topView: label)
        
        downloadedImagesField.setupView(labelText: "images".localize(), text: String(syncResult.imagesLoaded))
        syncSection.addSubviewAtTop(downloadedImagesField, topView: downloadedIssuesField)
        
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = 100
        progressSlider.value = Float(syncResult.downloadProgress)
        syncSection.addSubviewAtTop(progressSlider, topView: downloadedImagesField)
            .bottom(syncSection.bottomAnchor, inset: -defaultInset)
        
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

