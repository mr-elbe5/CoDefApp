/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class IssuePdfViewController: PDFViewController {
    
    var issue: IssueData
    
    init(issue: IssueData){
        self.issue = issue
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "\("pdf".localize()) \("for".localize()) \(issue.name)"
        super.loadView()
        
    }
    
    override func createPDF() -> Data{
        pdfCreator.createIssuePDF(issue: issue)
    }
    
}

extension PDFRenderer {
    
    func createIssuePDF(issue: IssueData) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Defect and Issue Tracker",
            kCGPDFContextTitle: issue.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "issueReport".localize())
            addIssueContent(issue: issue)
        }
        return data
    }
    
    func addIssueContent(issue: IssueData){
        addLine(label: "name".localize(), text: issue.name)
        addLine(label: "id".localize(), text: String(issue.displayId))
        if !issue.description.isEmpty{
            addLine(label: "description".localize(), text: issue.description)
        }
        if !issue.lot.isEmpty{
            addLine(label: "lot".localize(), text: issue.lot)
        }
        addLine(label: "creator".localize(), text: issue.creatorName)
        addLine(label: "creationDate".localize(), text: issue.creationDate.dateString())
        addLine(label: "status".localize(), text: issue.status.rawValue.localize())
        addLine(label: "assignedTo".localize(), text: issue.assignedUserName)
        addLine(label: "dueDate".localize(), text: issue.dueDate.dateTimeString())
        issue.assertPlanImage()
        if let img = issue.planImage{
            addLine(label: "position".localize(), image: img, maxHeight: pageRect.height * 0.2)
        }
        addSpacer()
        if !issue.images.isEmpty{
            addLine(label: "images".localize(), text: "")
            addLine(label: "", images: issue.images, maxHeight: pageRect.height * 0.2)
        }
        addSpacer()
        for feedback in issue.feedbacks{
            addLine()
            addLine(text: "feedback".localize(), type: .header3)
            addLine(label: "context".localize(), text: "feedbackContext".localize(param1: issue.scope?.project?.name ?? "", param2: issue.scope?.name ?? "", param3: issue.name))
            addFeedbackContent(feedback: feedback)
        }
    }
    
    func addFeedbackContent(feedback: FeedbackData){
        addLine(label: "on".localize(), text: feedback.creationDate.dateTimeString())
        addLine(label: "previousAssignment".localize(), text: feedback.previousAssignedUserName)
        addLine(label: "comment".localize(), text: feedback.comment)
        
        addLine(label: "status".localize(), text: feedback.status.rawValue.localize())
        addLine(label: "newAssignment".localize(), text: feedback.assignedUserName)
        if !feedback.images.isEmpty{
            addLine(label: "images".localize(), text: "")
            addLine(label: "", images: feedback.images, maxHeight: pageRect.height * 0.2)
        }
    }
    
}
