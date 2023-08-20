/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateDefectStatusViewController: EditViewController {
    
    var defect: DefectData
    var statusData : DefectStatusData
    
    var delegate: ProcessingStatusChangeDelegate? = nil
    
    var descriptionField = LabeledTextareaInput()
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledCompanySelectField()
    var notifiedField = LabeledCheckbox()
    
    let imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        CreateStatusDataInfoViewController()
    }
    
    init(defect: DefectData){
        statusData = DefectStatusData(defect: defect)
        self.defect = defect
        imageCollectionView = ImageCollectionView(images: statusData.images, enableDelete: true)
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
        descriptionField.setupView(labelText: "description".localizeWithColonAsMandatory(), text: statusData.description)
        contentView.addSubviewAtTop(descriptionField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: statusData.status)
        contentView.addSubviewAtTop(statusField, topView: descriptionField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupCompanies(companies: statusData.projectCompanies, currentCompanyId: statusData.assignedCompanyId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        addImageSection(below: notifiedField.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        statusData.images.remove(obj: image)
        statusData.changed()
        statusData.saveData()
        self.imageCollectionView.images.remove(obj: image)
        self.imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !descriptionField.text.isEmpty{
            statusData.description = descriptionField.text
            statusData.status = statusField.selectedStatus
            statusData.assignedCompanyId = assignField.selectedCompany?.id ?? 0
            defect.statusChanges.append(statusData)
            defect.status = statusData.status
            defect.assignedCompanyId = statusData.assignedCompanyId
            defect.notified = notifiedField.isOn
            statusData.synchronized = false
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
            statusData.images.append(image)
            statusData.changed()
            imageCollectionView.images.append(image)
            statusData.saveData()
            imageCollectionView.updateHeightConstraint()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageData) {
        statusData.images.append(photo)
        statusData.changed()
        imageCollectionView.images.append(photo)
        statusData.saveData()
        imageCollectionView.updateHeightConstraint()
        imageCollectionView.reloadData()
    }
    
}

class CreateStatusDataInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("defectStatusEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("defectStatusEditInfoText".localize()))
    }
    
}
