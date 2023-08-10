/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class ProjectPdfViewController: PDFViewController {
    
    var project: ProjectData
    
    init(project: ProjectData){
        self.project = project
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "\("report".localize()) \("for".localize()) \(project.name)"
        super.loadView()
        
    }
    
    override func createPDF() -> Data{
        pdfCreator.createProjectPDF(project: project)
    }
    
}

extension PDFRenderer {
    
    func createProjectPDF(project: ProjectData) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Defect and Issue Tracker",
            kCGPDFContextTitle: project.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "projectReport".localize())
            addProjectContent(project: project)
        }
        return data
    }
    
    func addProjectContent(project: ProjectData){
        addLine(label: "name".localize(), text: project.name)
        if !project.description.isEmpty{
            addLine(label: "description".localize(), text: project.description)
        }
        addSpacer()
        for scope in project.filteredScopes{
            addLine()
            addLine(text: "scope".localize(), type: .header2)
            addLine(label: "context".localize(), text: "scopeContext".localize(param: project.name))
            addScopeContent(scope: scope)
        }
        addLine()
    }
    
}

