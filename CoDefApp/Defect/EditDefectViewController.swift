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
    
    var descriptionField = LabeledTextareaInput()
    var notifiedField = LabeledCheckbox()
    var phaseField = LabeledPhaseSelectField()
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledCompanySelectField()
    var dueDateField = LabeledDatePicker()
    var positionCommentField = LabeledTextareaInput()
    
    var planView : UnitPlanView? = nil
    
    var imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        EditDefectInfoViewController()
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
        title = defect.displayName
        modalPresentationStyle = .fullScreen
        super.loadView()
    }
    
    override func setupContentView() {
        
        descriptionField.setupView(labelText: "description".localizeWithColonAsMandatory(), text: defect.description)
        contentView.addSubviewAtTop(descriptionField)
        
        phaseField.setup(labelText: "projectPhase".localizeWithColonAsMandatory(), currentPhase: defect.projectPhase)
        contentView.addSubviewAtTop(phaseField, topView: descriptionField)
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: defect.status)
        contentView.addSubviewAtTop(statusField, topView: phaseField)
        
        assignField.setupView(labelText: "assignedTo".localizeWithColonAsMandatory())
        assignField.setupCompanies(companies: defect.unit.projectCompanies, currentCompanyId: defect.assignedId)
        contentView.addSubviewAtTop(assignField, topView: statusField)
        
        var lastView : UIView = assignField
        
        if AppState.shared.useNotified{
            notifiedField.setup(title: "notified".localizeWithColon(), isOn: defect.notified)
            contentView.addSubviewAtTop(notifiedField, topView: lastView)
            lastView = notifiedField
        }
        
        dueDateField.setupView(labelText: "dueDate".localizeWithColonAsMandatory(), date: defect.dueDate1)
        dueDateField.setMinMaxDate(minDate: Date(), maxDate: Date.distantFuture)
        contentView.addSubviewAtTop(dueDateField, topView: lastView)
        lastView = dueDateField
        
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
        
        positionCommentField.setupView(labelText: "positionComment".localizeWithColon(), text: defect.positionComment)
        contentView.addSubviewAtTop(positionCommentField, topView: lastView)
        
        addImageSection(below: positionCommentField.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        defect.images.remove(obj: image)
        defect.changed()
        defect.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !descriptionField.text.isEmpty, let assignedCompany = assignField.selectedCompany {
            defect.description = descriptionField.text
            defect.projectPhase = phaseField.selectedPhase
            defect.assignedId = assignedCompany.id
            defect.notified = notifiedField.isOn
            defect.dueDate1 = dueDateField.date
            defect.positionComment = positionCommentField.text
            if let unit = defect.unit, !unit.defects.contains(defect){
                unit.defects.append(defect)
                unit.changed()
            }
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
    
    override func imagePicked(image: ImageData) {
        defect.images.append(image)
        imageCollectionView.images.append(image)
        defect.changed()
        defect.saveData()
        imageCollectionView.updateHeightConstraint()
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

class EditDefectInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("defectEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("defectEditInfoText".localize()))
    }
    
}

