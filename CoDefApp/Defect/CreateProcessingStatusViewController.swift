/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateProcessingStatusViewController: EditViewController {
    
    var defect: DefectData
    var processingStatus : ProcessingStatusData
    
    var delegate: ProcessingStatusDelegate? = nil
    
    var commentField = LabeledTextareaInput()
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledUserSelectField()
    var notifiedField = LabeledCheckbox()
    
    let imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        CreateProcessingStatusInfoViewController()
    }
    
    init(defect: DefectData){
        processingStatus = ProcessingStatusData(defect: defect)
        self.defect = defect
        imageCollectionView = ImageCollectionView(images: processingStatus.images, enableDelete: true)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "processingStatus".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        commentField.setupView(labelText: "comment".localizeWithColonAsMandatory(), text: processingStatus.comment)
        contentView.addSubviewAtTop(commentField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: processingStatus.status)
        contentView.addSubviewAtTop(statusField, topView: commentField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupUsers(users: processingStatus.projectUsers, currentUserId: processingStatus.assignedUserId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        addImageSection(below: notifiedField.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageFile) {
        processingStatus.images.remove(obj: image)
        processingStatus.changed()
        processingStatus.saveData()
        self.imageCollectionView.images.remove(obj: image)
        self.imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !commentField.text.isEmpty{
            processingStatus.comment = commentField.text
            processingStatus.status = statusField.selectedStatus
            processingStatus.assignedUserId = assignField.selectedUser?.uuid ?? .NIL
            defect.processingStatuses.append(processingStatus)
            defect.status = processingStatus.status
            defect.assignedUserId = processingStatus.assignedUserId
            defect.notified = notifiedField.isOn
            processingStatus.isNew = false
            defect.changed()
            defect.saveData()
            delegate?.statusChanged()
            return true
        }
        else{
            showError("mandatoryFieldsError")
        }
        return false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let image = ImageFile()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            processingStatus.images.append(image)
            processingStatus.changed()
            imageCollectionView.images.append(image)
            processingStatus.saveData()
            imageCollectionView.updateHeightConstraint()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageFile) {
        processingStatus.images.append(photo)
        processingStatus.changed()
        imageCollectionView.images.append(photo)
        processingStatus.saveData()
        imageCollectionView.updateHeightConstraint()
        imageCollectionView.reloadData()
    }
    
}

class CreateProcessingStatusInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("processingStatusEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("processingStatusEditInfoText".localize()))
    }
    
}
