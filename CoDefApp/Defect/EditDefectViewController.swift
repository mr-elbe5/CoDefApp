/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class EditDefectViewController: EditViewController {
    
    var defect: DefectData
    
    var delegate: DefectDelegate? = nil
    
    var nameField = LabeledTextInput()
    var descriptionField = LabeledTextareaInput()
    var notifiedField = LabeledCheckbox()
    
    var planView : UnitPlanView? = nil
    
    var imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        EditIssueInfoViewController()
    }
    
    init(defect: DefectData){
        self.defect = defect
        imageCollectionView = ImageCollectionView(images: defect.images, enableDelete: true)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "defect".localize()
        modalPresentationStyle = .fullScreen
        super.loadView()
    }
    
    override func setupContentView() {
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: defect.name)
        contentView.addSubviewAtTop(nameField)
        
        descriptionField.setupView(labelText: "description".localizeWithColon(), text: defect.description)
        contentView.addSubviewAtTop(descriptionField, topView: nameField)
        
        let statusView = LabeledText()
        statusView.setupView(labelText: "status".localizeWithColon(), text: defect.status.rawValue.localize())
        contentView.addSubviewAtTop(statusView, topView: descriptionField)
        
        let assignedView = LabeledText()
        assignedView.setupView(labelText: "assignedTo".localizeWithColonAsMandatory(), text: defect.assignedCompanyName)
        contentView.addSubviewAtTop(assignedView, topView: statusView)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: defect.notified)
        contentView.addSubviewAtTop(notifiedField, topView: assignedView)
        
        var lastView : UIView = notifiedField
        
        if let plan = defect.unit?.plan{
            let image = plan.getImage()
            let label = UILabel(header: "position".localizeWithColon())
            contentView.addSubviewWithAnchors(label, top: lastView.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
            let planButton = IconButton(icon: "pencil", backgroundColor: .systemBackground, withBorder: true)
            planButton.addAction(UIAction(){ action in
                let controller = EditDefectPositionViewController(defect: self.defect, plan: plan)
                controller.positionDelegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(planButton, top: lastView.bottomAnchor, insets: wideInsets)
                .centerX(contentView.centerXAnchor)
            let planView = UnitPlanView(plan: image)
            planView.addMarker(defect: defect)
            contentView.addSubviewAtTop(planView, topView: planButton)
            self.planView = planView
            lastView = planView
        }
        
        addImageSection(below: lastView.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        defect.images.remove(obj: image)
        defect.changed()
        defect.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            defect.name = nameField.text
            defect.description = descriptionField.text
            defect.notified = notifiedField.isOn
            defect.changed()
            defect.saveData()
            delegate?.defectChanged()
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
            defect.images.append(image)
            image.isNew = false
            imageCollectionView.images.append(image)
            defect.changed()
            defect.saveData()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageData) {
        defect.images.append(photo)
        imageCollectionView.images.append(photo)
        photo.isNew = false
        defect.changed()
        defect.saveData()
        imageCollectionView.reloadData()
    }
    
}

extension EditDefectViewController: DefectPositionDelegate{
    
    func positionChanged(position: CGPoint) {
        defect.position = position
        planView?.updateMarkers()
        defect.createPlanImage()
    }
    
}

class EditIssueInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("issueEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("issueEditInfoText".localize()))
    }
    
}

