/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class CreateDefectViewController: EditDefectViewController {
    
    var unit: UnitData
    
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledUserSelectField()
    var dueDateField = LabeledDatePicker()
    
    override var infoViewController: InfoViewController?{
        CreateIssueInfoViewController()
    }
    
    init(unit: UnitData){
        self.unit = unit
        let defect = DefectData()
        defect.unit = unit
        super.init(defect: defect)
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
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: defect.name)
        contentView.addSubviewAtTop(nameField)
        
        descriptionField.setupView(labelText: "description".localizeWithColon(), text: defect.description)
        contentView.addSubviewAtTop(descriptionField, topView: nameField)
        
        lotField.setupView(labelText: "lot".localizeWithColon(), text: defect.lot)
        contentView.addSubviewAtTop(lotField, topView: descriptionField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: defect.status)
        contentView.addSubviewAtTop(statusField, topView: lotField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColon())
        assignField.setupUsers(users: defect.projectUsers, currentUserId: defect.assignedUserId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        notifiedField.setup(title: "notified".localizeWithColon(), isOn: false)
        contentView.addSubviewAtTop(notifiedField, topView: assignField)
        
        dueDateField.setupView(labelText: "dueDate".localizeWithColonAsMandatory(), date: Date())
        dueDateField.setMinMaxDate(minDate: Date(), maxDate: Date.distantFuture)
        contentView.addSubviewAtTop(dueDateField, topView: notifiedField)
        
        var lastView : UIView = dueDateField
        
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
    
    override func deleteImageData(image: ImageFile) {
        defect.images.remove(obj: image)
        defect.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            defect.name = nameField.text
            defect.description = descriptionField.text
            defect.lot = lotField.text
            defect.assertDisplayId()
            defect.assignedUserId = assignField.selectedUser?.uuid ?? .NIL
            defect.notified = notifiedField.isOn
            defect.dueDate = dueDateField.date
            defect.status = statusField.selectedStatus
            unit.issues.append(defect)
            defect.isNew = false
            defect.changed()
            unit.changed()
            unit.saveData()
            delegate?.defectChanged()
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

