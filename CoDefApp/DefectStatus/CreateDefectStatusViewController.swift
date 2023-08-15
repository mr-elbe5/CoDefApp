/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateDefectStatusViewController: EditViewController {
    
    var defect: DefectData
    var defectStatus : DefectStatusData
    
    var delegate: ProcessingStatusDelegate? = nil
    
    var commentField = LabeledTextareaInput()
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledCompanySelectField()
    var notifiedField = LabeledCheckbox()
    
    let imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        CreateDefectStatusInfoViewController()
    }
    
    init(defect: DefectData){
        defectStatus = DefectStatusData(defect: defect)
        self.defect = defect
        imageCollectionView = ImageCollectionView(images: defectStatus.images, enableDelete: true)
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
        commentField.setupView(labelText: "comment".localizeWithColonAsMandatory(), text: defectStatus.comment)
        contentView.addSubviewAtTop(commentField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: defectStatus.status)
        contentView.addSubviewAtTop(statusField, topView: commentField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupCompanies(companies: defectStatus.projectCompanies, currentCompanyId: defectStatus.assignedCompanyId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        addImageSection(below: notifiedField.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageFile) {
        defectStatus.images.remove(obj: image)
        defectStatus.changed()
        defectStatus.saveData()
        self.imageCollectionView.images.remove(obj: image)
        self.imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !commentField.text.isEmpty{
            defectStatus.comment = commentField.text
            defectStatus.status = statusField.selectedStatus
            defectStatus.assignedCompanyId = assignField.selectedCompany?.id ?? 0
            defect.processingStatuses.append(defectStatus)
            defect.status = defectStatus.status
            defect.assignedCompanyId = defectStatus.assignedCompanyId
            defect.notified = notifiedField.isOn
            defectStatus.synchronized = false
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
            defectStatus.images.append(image)
            defectStatus.changed()
            imageCollectionView.images.append(image)
            defectStatus.saveData()
            imageCollectionView.updateHeightConstraint()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageFile) {
        defectStatus.images.append(photo)
        defectStatus.changed()
        imageCollectionView.images.append(photo)
        defectStatus.saveData()
        imageCollectionView.updateHeightConstraint()
        imageCollectionView.reloadData()
    }
    
}

class CreateDefectStatusInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("defectStatusEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("defectStatusEditInfoText".localize()))
    }
    
}
