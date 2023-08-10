/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateIssueViewController: EditIssueViewController {
    
    var scope: ScopeData
    
    var statusField = LabeledIssueStatusSelectView()
    var assignField = LabeledUserSelectField()
    var dueDateField = LabeledDatePicker()
    
    override var infoViewController: InfoViewController?{
        CreateIssueInfoViewController()
    }
    
    init(scope: ScopeData){
        self.scope = scope
        let issue = IssueData()
        issue.scope = scope
        super.init(issue: issue)
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
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: issue.status)
        contentView.addSubviewAtTop(statusField, topView: lotField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupUsers(users: issue.projectUsers, currentUserId: issue.assignedUserId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        dueDateField.setupView(labelText: "dueDate".localizeWithColonAsMandatory(), date: Date())
        dueDateField.setMinMaxDate(minDate: Date(), maxDate: Date.distantFuture)
        contentView.addSubviewAtTop(dueDateField, topView: notifiedField)
        
        var lastView : UIView = dueDateField
        
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
        issue.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            issue.name = nameField.text
            issue.description = descriptionField.text
            issue.lot = lotField.text
            issue.assertDisplayId()
            issue.assignedUserId = assignField.selectedUser?.uuid ?? .NIL
            issue.notified = notifiedField.isOn
            issue.dueDate = dueDateField.date
            issue.status = statusField.selectedStatus
            scope.issues.append(issue)
            issue.isNew = false
            issue.changed()
            scope.changed()
            scope.saveData()
            delegate?.issueChanged()
            return true
        }
        else{
            showError("mandatoryFieldsError")
        }
        return false
    }
    
}

class CreateIssueInfoViewController: EditIssueInfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("issueEditInfoHeader".localize()))
        block.addSpacer()
        block.addArrangedSubview(InfoText("issueEditInfoText".localize()))
    }
    
}

