/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateStatusChangeViewController: EditViewController {
    
    var defect: DefectData
    var statusChange : StatusChangeData
    
    var delegate: StatusChangeDelegate? = nil
    
    var descriptionField = LabeledTextareaInput()
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledCompanySelectField()
    var notifiedField = LabeledCheckbox()
    
    let imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        CreateStatusDataInfoViewController()
    }
    
    init(defect: DefectData){
        statusChange = StatusChangeData(defect: defect)
        self.defect = defect
        imageCollectionView = ImageCollectionView(images: statusChange.images, enableDelete: true)
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
        descriptionField.setupView(labelText: "description".localizeWithColonAsMandatory(), text: statusChange.description)
        contentView.addSubviewAtTop(descriptionField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: statusChange.status)
        contentView.addSubviewAtTop(statusField, topView: descriptionField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupCompanies(companies: statusChange.projectCompanies, currentCompanyId: statusChange.assignedCompanyId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        addImageSection(below: notifiedField.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        statusChange.images.remove(obj: image)
        statusChange.changed()
        statusChange.saveData()
        self.imageCollectionView.images.remove(obj: image)
        self.imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !descriptionField.text.isEmpty{
            statusChange.description = descriptionField.text
            statusChange.status = statusField.selectedStatus
            statusChange.assignedCompanyId = assignField.selectedCompany?.id ?? 0
            defect.status = statusChange.status
            defect.assignedCompanyId = statusChange.assignedCompanyId
            defect.notified = notifiedField.isOn
            defect.statusChanges.append(statusChange)
            statusChange.setSynchronized(false)
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
        let image = ImageData()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            statusChange.images.append(image)
            statusChange.changed()
            imageCollectionView.images.append(image)
            statusChange.saveData()
            imageCollectionView.updateHeightConstraint()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageData) {
        statusChange.images.append(photo)
        statusChange.changed()
        imageCollectionView.images.append(photo)
        statusChange.saveData()
        imageCollectionView.updateHeightConstraint()
        imageCollectionView.reloadData()
    }
    
}

class CreateStatusDataInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("statusChangeEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("statusChangeEditInfoText".localize()))
    }
    
}