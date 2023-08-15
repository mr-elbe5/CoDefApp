/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class UnitPdfViewController: PDFViewController {
    
    var scope: UnitData
    
    init(scope: UnitData){
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
    
    func createScopePDF(scope: UnitData) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Construction Defect Tracker",
            kCGPDFContextTitle: scope.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "unitReport".localize())
            addScopeContent(scope: scope)
        }
        return data
    }
    
    func addScopeContent(scope: UnitData){
        addLine(label: "name".localize(), text: scope.name)
        if !scope.description.isEmpty{
            addLine(label: "description".localize(), text: scope.description)
        }
        if let img = scope.getPlanImage(){
            addLine(label: "defects".localize(), image: img, maxHeight: 0)
        }
        addSpacer()
        for issue in scope.filteredDefects{
            addLine()
            addLine(text: "defect".localize(), type: .header3)
            addLine(label: "context".localize(), text: "defectContext".localize(param1: scope.project?.name ?? "", param2: scope.name))
            addDefectContent(defect: issue)
        }
    }
    
}

