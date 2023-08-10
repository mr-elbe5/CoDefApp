/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class EditIssueViewController: EditViewController {
    
    var issue: IssueData
    
    var delegate: IssueDelegate? = nil
    
    var nameField = LabeledTextInput()
    var descriptionField = LabeledTextareaInput()
    var lotField = LabeledTextInput()
    var notifiedField = LabeledCheckbox()
    
    var planView : ScopePlanView? = nil
    
    var imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        EditIssueInfoViewController()
    }
    
    init(issue: IssueData){
        self.issue = issue
        imageCollectionView = ImageCollectionView(images: issue.images, enableDelete: true)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "issue".localize()
        modalPresentationStyle = .fullScreen
        super.loadView()
    }
    
    override func setupContentView() {
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: issue.name)
        contentView.addSubviewAtTop(nameField)
        
        descriptionField.setupView(labelText: "description".localizeWithColon(), text: issue.description)
        contentView.addSubviewAtTop(descriptionField, topView: nameField)
        
        lotField.setupView(labelText: "lot".localizeWithColon(), text: issue.lot)
        contentView.addSubviewAtTop(lotField, topView: descriptionField)
        
        let statusView = LabeledText()
        statusView.setupView(labelText: "status".localizeWithColon(), text: issue.status.rawValue.localize())
        contentView.addSubviewAtTop(statusView, topView: lotField)
        
        let assignedView = LabeledText()
        assignedView.setupView(labelText: "assignedTo".localizeWithColonAsMandatory(), text: issue.assignedUserName)
        contentView.addSubviewAtTop(assignedView, topView: statusView)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: issue.notified)
        contentView.addSubviewAtTop(notifiedField, topView: assignedView)
        
        var lastView : UIView = notifiedField
        
        if let plan = issue.scope?.plan{
            let image = plan.getImage()
            let label = UILabel(header: "position".localizeWithColon())
            contentView.addSubviewWithAnchors(label, top: lastView.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
            let planButton = IconButton(icon: "pencil", backgroundColor: .systemBackground, withBorder: true)
            planButton.addAction(UIAction(){ action in
                let controller = EditIssuePositionViewController(issue: self.issue, plan: plan)
                controller.positionDelegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }, for: .touchDown)
            contentView.addSubviewWithAnchors(planButton, top: lastView.bottomAnchor, insets: wideInsets)
                .centerX(contentView.centerXAnchor)
            let planView = ScopePlanView(plan: image)
            planView.addMarker(issue: issue)
            contentView.addSubviewAtTop(planView, topView: planButton)
            self.planView = planView
            lastView = planView
        }
        
        addImageSection(below: lastView.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageFile) {
        issue.images.remove(obj: image)
        issue.changed()
        issue.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            issue.name = nameField.text
            issue.description = descriptionField.text
            issue.lot = lotField.text
            issue.notified = notifiedField.isOn
            issue.changed()
            issue.saveData()
            delegate?.issueChanged()
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
            issue.images.append(image)
            image.isNew = false
            imageCollectionView.images.append(image)
            issue.changed()
            issue.saveData()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageFile) {
        issue.images.append(photo)
        imageCollectionView.images.append(photo)
        photo.isNew = false
        issue.changed()
        issue.saveData()
        imageCollectionView.reloadData()
    }
    
}

extension EditIssueViewController: IssuePositionDelegate{
    
    func positionChanged(position: CGPoint) {
        issue.position = position
        planView?.updateMarkers()
        issue.createPlanImage()
    }
    
}

class EditIssueInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("issueEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("issueEditInfoText".localize()))
    }
    
}

