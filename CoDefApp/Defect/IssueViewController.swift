/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class IssueViewController: ScrollViewController, ImageCollectionDelegate {
    
    var issue : IssueData
    
    var dataSection = ArrangedSectionView()
    var feedbackSection = UIView()
    
    var delegate: IssueDelegate? = nil
    
    init(issue: IssueData){
        self.issue = issue
        super.init()
        issue.assertPlanImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "issue".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = IssuePdfViewController(issue: self.issue)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if CurrentUser.hasEditRight(for: issue){
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditIssueViewController(issue: self.issue)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
                if let scope = self.issue.scope{
                    self.showDestructiveApprove(text: "deleteInfo".localize()){
                        scope.removeIssue(self.issue)
                        scope.changed()
                        scope.saveData()
                        self.delegate?.issueChanged()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }))
        }
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = IssueInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView(){
        contentView.addSubviewAtTop(dataSection, insets: defaultInsets)
        setupDataSection()
        contentView.addSubviewAtTop(feedbackSection, topView: dataSection, insets: defaultInsets)
            .bottom(contentView.bottomAnchor)
        setupFeedbackSection()
    }
    
    func setupDataSection(){
        let nameView = LabeledText()
        nameView.setupView(labelText: "name".localizeWithColon(), text: issue.name)
        dataSection.addArrangedSubview(nameView)
        
        let idView = LabeledText()
        idView.setupView(labelText: "id".localizeWithColon(), text: String(issue.displayId))
        dataSection.addArrangedSubview(idView)
        
        let descriptionView = LabeledText()
        descriptionView.setupView(labelText: "description".localizeWithColon(), text: issue.description)
        dataSection.addArrangedSubview(descriptionView)
        
        let statusView = LabeledText()
        statusView.setupView(labelText: "status".localizeWithColon(), text: issue.status.rawValue.localize())
        dataSection.addArrangedSubview(statusView)
        
        let assignedView = LabeledText()
        assignedView.setupView(labelText: "assignedTo".localizeWithColon(), text: issue.assignedUserName)
        dataSection.addArrangedSubview(assignedView)
        
        let notifiedView = LabeledText()
        notifiedView.setupView(labelText: "notified".localizeWithColon(), text: issue.notified ? "true".localize() : "false".localize())
        dataSection.addArrangedSubview(notifiedView)
        issue.assertPlanImage()
        if let plan = issue.planImage{
            let label = UILabel(header: "position".localizeWithColon())
            dataSection.addArrangedSubview(label)
            dataSection.addSpacer()
            let planView = UIView()
            let imageView = UIImageView(image: plan)
            planView.addSubviewWithAnchors(imageView, top: planView.topAnchor, leading: planView.leadingAnchor, bottom: planView.bottomAnchor)
                .width(IssueData.planCropSize.width)
                .height(IssueData.planCropSize.height)
            dataSection.addArrangedSubview(planView)
        }
        
        let label = UILabel(header: "images".localizeWithColon())
        dataSection.addArrangedSubview(label)
        
        let imageCollectionView = ImageCollectionView(images: issue.images, enableDelete: true)
        imageCollectionView.imageDelegate = self
        dataSection.addArrangedSubview(imageCollectionView)
        
    }
    
    func updateDataSection(){
        dataSection.removeAllArrangedSubviews()
        setupDataSection()
    }
    
    func setupFeedbackSection(){
        let headerLabel = UILabel(header: "feedbacks".localize())
        feedbackSection.addSubviewAtTop(headerLabel, insets: defaultInsets)
        var lastView: UIView = headerLabel
        
        for feedback in issue.feedbacks{
            let feeedbackView = ArrangedSectionView()
            feedbackSection.addSubviewWithAnchors(feeedbackView, top: lastView.bottomAnchor, leading: feedbackSection.leadingAnchor, trailing: feedbackSection.trailingAnchor, insets: verticalInsets)
            setupFeedbackView(view: feeedbackView, feedback: feedback);
            lastView = feeedbackView
        }
        let addFeedbackButton = TextButton(text: "addFeedback".localize())
        addFeedbackButton.addAction(UIAction(){ (action) in
            if !self.issue.projectUsers.isEmpty{
                let controller = CreateFeedbackViewController(issue: self.issue)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else{
                self.showError("noUsersError")
            }
        }, for: .touchDown)
        feedbackSection.addSubviewAtTopCentered(addFeedbackButton, topView: lastView)
            .bottom(feedbackSection.bottomAnchor, inset: -2*defaultInset)
    }
    
    func setupFeedbackView(view: ArrangedSectionView, feedback: FeedbackData){
        let createdLine = LabeledText()
        let txt = "\("on".localize()) \(feedback.creationDate.dateString()) \("by".localize()) \(feedback.creatorName)"
        createdLine.setupView(labelText: "created".localizeWithColon(), text: txt)
        view.addArrangedSubview(createdLine)
        
        let statusLine = LabeledText()
        statusLine.setupView(labelText: "status".localizeWithColon(), text: feedback.status.rawValue.localize())
        view.addArrangedSubview(statusLine)
        
        let previousAssignmentLine = LabeledText()
        previousAssignmentLine.setupView(labelText: "previousAssignment".localizeWithColon(), text: feedback.previousAssignedUserName)
        view.addArrangedSubview(previousAssignmentLine)
        
        let assignmentLine = LabeledText()
        assignmentLine.setupView(labelText: "assignedTo".localizeWithColon(), text: feedback.assignedUserName)
        view.addArrangedSubview(assignmentLine)
        
        let dueDateLine = LabeledText()
        dueDateLine.setupView(labelText: "dueDate".localizeWithColon(), text: feedback.dueDate.dateString())
        view.addArrangedSubview(dueDateLine)
        
        let commentLine = LabeledText()
        commentLine.setupView(labelText: "comment".localizeWithColon(), text: feedback.comment)
        view.addArrangedSubview(commentLine)
        
        if !feedback.images.isEmpty{
            let label = UILabel(header: "images".localizeWithColon())
            view.addArrangedSubview(label)
            
            let imageCollectionView = ImageCollectionView(images: feedback.images, enableDelete: false)
            imageCollectionView.imageDelegate = self
            view.addArrangedSubview(imageCollectionView)
        }
    }
    
    func updateFeedbackSection(){
        feedbackSection.removeAllSubviews()
        setupFeedbackSection()
    }
    
    override func deleteImageData(image: ImageFile) {
        issue.images.remove(obj: image)
        issue.changed()
        issue.saveData()
        updateDataSection()
    }
    
}

extension IssueViewController: IssueDelegate{
    
    func issueChanged() {
        updateDataSection()

        delegate?.issueChanged()
    }
    
}

extension IssueViewController: FeedbackDelegate{
    
    func feedbackChanged() {
        updateFeedbackSection()
    }
    
}

class IssueInfoViewController: InfoViewController {
    
    override func setupInfos(){
        var block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "issueEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "doc.text", text: "issueReportSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "issueDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
        stackView.addSpacer()
        block = addBlock()
        block.addArrangedSubview(InfoHeader("issueFeedbacksInfoHeader".localize()))
        block.addArrangedSubview(InfoText("issueFeedbacksInfoText".localize()))
    }
    
}
