/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class DefectViewController: ScrollViewController, ImageCollectionDelegate {
    
    var defect : DefectData
    
    var dataSection = ArrangedSectionView()
    var processingSection = UIView()
    
    var delegate: DefectDelegate? = nil
    
    init(defect: DefectData){
        self.defect = defect
        super.init()
        defect.assertPlanImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = defect.displayName
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = DefectPdfViewController(defect: self.defect)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if AppState.shared.standalone || !defect.isOnServer{
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditDefectViewController(defect: self.defect)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            if let unit = self.defect.unit{
                self.showDestructiveApprove(text: "deleteInfo".localize(), onApprove: {
                    unit.removeDefect(self.defect)
                    unit.changed()
                    unit.saveData()
                    self.delegate?.defectChanged()
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = DefectInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(dataSection, insets: defaultInsets)
        setupDataSection()
        contentView.addSubviewAtTop(processingSection, topView: dataSection, insets: defaultInsets)
            .bottom(contentView.bottomAnchor)
        setupProcessingSection()
    }
    
    func setupDataSection(){
        let nameView = LabeledText()
        nameView.setupView(labelText: "name".localizeWithColon(), text: defect.displayName)
        dataSection.addArrangedSubview(nameView)
        
        let idView = LabeledText()
        idView.setupView(labelText: "id".localizeWithColon(), text: String(defect.id))
        dataSection.addArrangedSubview(idView)
        
        let descriptionView = LabeledText()
        descriptionView.setupView(labelText: "description".localizeWithColon(), text: defect.description)
        dataSection.addArrangedSubview(descriptionView)
        
        let remainingWorkView = UILabel(text: "remainingWork".localize())
        dataSection.addArrangedSubview(remainingWorkView)
        
        let positionCommentView = LabeledText()
        positionCommentView.setupView(labelText: "positionComment".localizeWithColon(), text: defect.positionComment)
        dataSection.addArrangedSubview(positionCommentView)
        
        let phaseView = LabeledText()
        phaseView.setupView(labelText: "projectPhase".localizeWithColon(), text: defect.projectPhase.rawValue.localize())
        dataSection.addArrangedSubview(phaseView)
        
        let statusView = LabeledText()
        statusView.setupView(labelText: "status".localizeWithColon(), text: defect.status.rawValue.localize())
        dataSection.addArrangedSubview(statusView)
        
        let assignedView = LabeledText()
        assignedView.setupView(labelText: "assignedTo".localizeWithColon(), text: defect.assignedCompanyName)
        dataSection.addArrangedSubview(assignedView)
        
        let dueDateView = LabeledText()
        dueDateView.setupView(labelText: "dueDate".localizeWithColon(), text: defect.dueDate.dateString())
        dataSection.addArrangedSubview(dueDateView)
        
        if AppState.shared.useNotified{
            let notifiedView = LabeledText()
            notifiedView.setupView(labelText: "notified".localizeWithColon(), text: defect.notified ? "true".localize() : "false".localize())
            dataSection.addArrangedSubview(notifiedView)
        }
        
        defect.assertPlanImage()
        if let plan = defect.planImage{
            let label = UILabel(header: "position".localizeWithColon())
            dataSection.addArrangedSubview(label)
            dataSection.addSpacer()
            let planView = UIView()
            let imageView = UIImageView(image: plan)
            planView.addSubviewWithAnchors(imageView, top: planView.topAnchor, leading: planView.leadingAnchor, bottom: planView.bottomAnchor)
                .width(DefectData.planCropSize.width)
                .height(DefectData.planCropSize.height)
            dataSection.addArrangedSubview(planView)
        }
        
        let label = UILabel(header: "images".localizeWithColon())
        dataSection.addArrangedSubview(label)
        
        let imageCollectionView = ImageCollectionView(images: defect.images, enableDelete: true)
        imageCollectionView.imageDelegate = self
        dataSection.addArrangedSubview(imageCollectionView)
        
    }
    
    func updateDataSection(){
        dataSection.removeAllArrangedSubviews()
        setupDataSection()
    }
    
    func setupProcessingSection(){
        let headerLabel = UILabel(header: "statusChanges".localize())
        processingSection.addSubviewAtTop(headerLabel, insets: defaultInsets)
        var lastView: UIView = headerLabel
        
        for feedback in defect.statusChanges{
            let feeedbackView = ArrangedSectionView()
            processingSection.addSubviewWithAnchors(feeedbackView, top: lastView.bottomAnchor, leading: processingSection.leadingAnchor, trailing: processingSection.trailingAnchor, insets: verticalInsets)
            setupProcessingStatusView(view: feeedbackView, statusData: feedback);
            lastView = feeedbackView
        }
        let addProcessingStatusButton = TextButton(text: "addStatusChange".localize())
        addProcessingStatusButton.addAction(UIAction(){ (action) in
            if !self.defect.projectUsers.isEmpty{
                let controller = CreateStatusChangeViewController(defect: self.defect)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                self.showError("noUsersError")
            }
        }, for: .touchDown)
        processingSection.addSubviewAtTopCentered(addProcessingStatusButton, topView: lastView)
            .bottom(processingSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func setupProcessingStatusView(view: ArrangedSectionView, statusData: DefectStatusData){
        let createdLine = LabeledText()
        let txt = "\("on".localize()) \(statusData.creationDate.asString()) \("by".localize()) \(statusData.creatorName)"
        createdLine.setupView(labelText: "created".localizeWithColon(), text: txt)
        view.addArrangedSubview(createdLine)
        
        let statusLine = LabeledText()
        statusLine.setupView(labelText: "status".localizeWithColon(), text: statusData.status.rawValue.localize())
        view.addArrangedSubview(statusLine)
        
        let assignmentLine = LabeledText()
        assignmentLine.setupView(labelText: "assignedTo".localizeWithColon(), text: statusData.assignedCompany?.name ?? "")
        view.addArrangedSubview(assignmentLine)
        
        let dueDateLine = LabeledText()
        dueDateLine.setupView(labelText: "dueDate".localizeWithColon(), text: statusData.dueDate.dateString())
        view.addArrangedSubview(dueDateLine)
        
        let commentLine = LabeledText()
        commentLine.setupView(labelText: "description".localizeWithColon(), text: statusData.description)
        view.addArrangedSubview(commentLine)
        
        if !statusData.images.isEmpty{
            let label = UILabel(header: "images".localizeWithColon())
            view.addArrangedSubview(label)
            
            let imageCollectionView = ImageCollectionView(images: statusData.images, enableDelete: false)
            imageCollectionView.imageDelegate = self
            view.addArrangedSubview(imageCollectionView)
        }
    }
    
    func updateFeedbackSection(){
        processingSection.removeAllSubviews()
        setupProcessingSection()
    }
    
    override func deleteImageData(image: ImageData) {
        defect.images.remove(obj: image)
        defect.changed()
        defect.saveData()
        updateDataSection()
    }
    
}

extension DefectViewController: DefectDelegate{
    
    func defectChanged() {
        updateDataSection()

        delegate?.defectChanged()
    }
    
}

extension DefectViewController: StatusChangeDelegate{
    
    func statusChanged() {
        updateFeedbackSection()
    }
    
}

class DefectInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "defectEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "doc.text", text: "defectReportSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "defectDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("statusChangeInfoHeader".localize()))
        block.addArrangedSubview(InfoText("statusChangeInfoText".localize()))
    }
    
}
