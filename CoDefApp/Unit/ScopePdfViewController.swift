/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class ScopePdfViewController: PDFViewController {
    
    var scope: ScopeData
    
    init(scope: ScopeData){
        self.scope = scope
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "\("pdf".localize()) \("for".localize()) \(scope.name)"
        super.loadView()
        
    }
    
    override func createPDF() -> Data{
        pdfCreator.createScopePDF(scope: scope)
    }
    
}

extension PDFRenderer {
    
    func createScopePDF(scope: ScopeData) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Defect and Issue Tracker",
            kCGPDFContextTitle: scope.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "scopeReport".localize())
            addScopeContent(scope: scope)
        }
        return data
    }
    
    func addScopeContent(scope: ScopeData){
        addLine(label: "name".localize(), text: scope.name)
        if !scope.description.isEmpty{
            addLine(label: "description".localize(), text: scope.description)
        }
        if let img = scope.getPlanImage(){
            addLine(label: "issues".localize(), image: img, maxHeight: 0)
        }
        addSpacer()
        for issue in scope.filteredIssues{
            addLine()
            addLine(text: "issue".localize(), type: .header3)
            addLine(label: "context".localize(), text: "issueContext".localize(param1: scope.project?.name ?? "", param2: scope.name))
            addIssueContent(issue: issue)
        }
    }
    
}

