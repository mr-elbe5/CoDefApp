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
    
    var descriptionField = LabeledTextareaInput().withTextColor(.black)
    var positionCommentField = LabeledTextareaInput().withTextColor(.black)
    var locationField = LabeledTextareaInput().withTextColor(.black)
    var remainingWorkField = LabeledCheckbox().withTextColor(.black)
    var notifiedField = LabeledCheckbox().withTextColor(.black)
    var phaseField = LabeledPhaseSelectField().withTextColor(.black) as! LabeledPhaseSelectField
    var statusField = LabeledDefectStatusSelectView().withTextColor(.black) as! LabeledDefectStatusSelectView
    var assignField = LabeledCompanySelectField().withTextColor(.black) as! LabeledCompanySelectField
    var dueDateField = LabeledDatePicker().withTextColor(.black)
    
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
        
        descriptionField.setupView(labelText: "defect".localizeWithColonAsMandatory(), text: defect.description)
        contentView.addSubviewAtTop(descriptionField)
        
        positionCommentField.setupView(labelText: "comment".localizeWithColon(), text: defect.comment)
        contentView.addSubviewAtTop(positionCommentField, topView: descriptionField)
        
        locationField.setupView(labelText: "defectLocation".localizeWithColon(), text: defect.location)
        contentView.addSubviewAtTop(locationField, topView: positionCommentField)
        
        var lastView : UIView = locationField
        
        remainingWorkField.setup(title: "remainingWork".localizeWithColon(), isOn: defect.remainingWork)
        contentView.addSubviewAtTop(remainingWorkField, topView: lastView)
        lastView = remainingWorkField
        
        phaseField.setup(labelText: "projectPhase".localizeWithColonAsMandatory(), currentPhase: defect.projectPhase)
        contentView.addSubviewAtTop(phaseField, topView: lastView)
        lastView = phaseField
        
        statusField.setupView(labelText: "status".localizeWithColonAsMandatory())
        statusField.setupStatuses(currentStatus: defect.status)
        contentView.addSubviewAtTop(statusField, topView: lastView)
        lastView = statusField
        
        assignField.setupView(labelText: "assignedTo".localizeWithColonAsMandatory())
        assignField.setupCompanies(companies: defect.unit.projectCompanies, currentCompanyId: defect.assignedId)
        contentView.addSubviewAtTop(assignField, topView: lastView)
        lastView = assignField
        
        if AppState.shared.useNotified{
            notifiedField.setup(title: "notified".localizeWithColon(), isOn: defect.notified)
            contentView.addSubviewAtTop(notifiedField, topView: lastView)
            lastView = notifiedField
        }
        
        dueDateField.setupView(labelText: "dueDate".localizeWithColonAsMandatory(), date: defect.dueDate1)
        dueDateField.setMinMaxDate(minDate: Date.localDate, maxDate: Date.distantFuture)
        contentView.addSubviewAtTop(dueDateField, topView: lastView)
        lastView = dueDateField
        
        if let plan = defect.unit?.plan{
            let image = plan.getImage()
            let label = UILabel(header: "position".localizeWithColon()).withTextColor(.black)
            contentView.addSubviewWithAnchors(label, top: lastView.bottomAnchor, leading: contentView.leadingAnchor, insets: defaultInsets)
            let planButton = IconButton(icon: "pencil", backgroundColor: .systemBackground, withBorder: true)
            planButton.addAction(UIAction(){ action in
                self.defect.remainingWork = self.remainingWorkField.isOn
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
        if !descriptionField.text.isEmpty, let assignedCompany = assignField.selectedCompany {
            defect.description = descriptionField.text
            defect.comment = positionCommentField.text
            defect.location = locationField.text
            defect.remainingWork = remainingWorkField.isOn
            defect.projectPhase = phaseField.selectedPhase
            defect.assignedId = assignedCompany.id
            defect.notified = notifiedField.isOn
            defect.dueDate1 = dueDateField.date
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

