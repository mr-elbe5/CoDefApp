/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import E5IOSUI

class CreateStatusChangeViewController: EditViewController {
    
    var defect: DefectData
    var statusChange : DefectStatusData
    
    var delegate: StatusChangeDelegate? = nil
    
    var descriptionField = LabeledTextareaInput().withTextColor(.black)
    var assignField = LabeledCompanySelectField().withTextColor(.black) as! LabeledCompanySelectField
    var statusField = LabeledDefectStatusSelectView().withTextColor(.black) as! LabeledDefectStatusSelectView
    var notifiedField = LabeledCheckbox().withTextColor(.black)
    
    let imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        CreateStatusDataInfoViewController()
    }
    
    init(defect: DefectData){
        statusChange = DefectStatusData(defect: defect)
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
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupCompanies(companies: statusChange.projectCompanies, currentCompanyId: statusChange.assignedId)
        contentView.addSubviewAtTop(assignField, topView: descriptionField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: defect.status)
        contentView.addSubviewAtTop(statusField, topView: assignField)
        
        var lastView: UIView = statusField
        
        if AppState.shared.useNotified{
            notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
            contentView.addSubviewAtTop(notifiedField, topView: lastView)
            lastView = notifiedField
        }
        
        addImageSection(below: lastView.bottomAnchor, imageCollectionView: imageCollectionView)
        
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
            statusChange.assignedId = assignField.selectedCompany?.id ?? 0
            statusChange.status = statusField.selectedStatus
            defect.assignedId = statusChange.assignedId
            defect.notified = notifiedField.isOn
            defect.statusChanges.append(statusChange)
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
    
    override func imagePicked(image: ImageData) {
        statusChange.images.append(image)
        statusChange.changed()
        imageCollectionView.images.append(image)
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
