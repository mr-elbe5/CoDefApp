/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateFeedbackViewController: EditViewController {
    
    var issue: IssueData
    var feedback : FeedbackData
    
    var delegate: FeedbackDelegate? = nil
    
    var commentField = LabeledTextareaInput()
    var statusField = LabeledIssueStatusSelectView()
    var assignField = LabeledUserSelectField()
    var notifiedField = LabeledCheckbox()
    
    let imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        CreateFeedbackInfoViewController()
    }
    
    init(issue: IssueData){
        feedback = FeedbackData(issue: issue)
        self.issue = issue
        imageCollectionView = ImageCollectionView(images: feedback.images, enableDelete: true)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "feedback".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        commentField.setupView(labelText: "comment".localizeWithColonAsMandatory(), text: feedback.comment)
        contentView.addSubviewAtTop(commentField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: feedback.status)
        contentView.addSubviewAtTop(statusField, topView: commentField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupUsers(users: feedback.projectUsers, currentUserId: feedback.assignedUserId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        addImageSection(below: notifiedField.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageFile) {
        feedback.images.remove(obj: image)
        feedback.changed()
        feedback.saveData()
        self.imageCollectionView.images.remove(obj: image)
        self.imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !commentField.text.isEmpty{
            feedback.comment = commentField.text
            feedback.status = statusField.selectedStatus
            feedback.assignedUserId = assignField.selectedUser?.uuid ?? .NIL
            issue.feedbacks.append(feedback)
            issue.status = feedback.status
            issue.assignedUserId = feedback.assignedUserId
            issue.notified = notifiedField.isOn
            feedback.isNew = false
            issue.changed()
            issue.saveData()
            delegate?.feedbackChanged()
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
            feedback.images.append(image)
            feedback.changed()
            imageCollectionView.images.append(image)
            feedback.saveData()
            imageCollectionView.updateHeightConstraint()
            imageCollectionView.reloadData()
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageFile) {
        feedback.images.append(photo)
        feedback.changed()
        imageCollectionView.images.append(photo)
        feedback.saveData()
        imageCollectionView.updateHeightConstraint()
        imageCollectionView.reloadData()
    }
    
}

class CreateFeedbackInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("feedbackEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("feedbackEditInfoText".localize()))
    }
    
}
