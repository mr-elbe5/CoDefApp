/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class UnitPdfViewController: PDFViewController {
    
    var unit: UnitData
    
    init(unit: UnitData){
        self.unit = unit
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "\("pdf".localize()) \("for".localize()) \(unit.displayName)"
        super.loadView()
        
    }
    
    override func createPDF() -> Data{
        pdfCreator.createUnitPDF(unit: unit)
    }
    
}

extension PDFRenderer {
    
    func createUnitPDF(unit: UnitData) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Construction Defect Tracker",
            kCGPDFContextTitle: unit.displayName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "unitReport".localize())
            addUnitContent(unit: unit)
        }
        return data
    }
    
    func addUnitContent(unit: UnitData){
        addLine(label: "name".localize(), text: unit.displayName)
        if !unit.description.isEmpty{
            addLine(label: "description".localize(), text: unit.description)
        }
        if let img = unit.getPlanImage(){
            addLine(label: "defectsAndRemainingWork".localize(), image: img, maxHeight: 0)
        }
        addSpacer()
        for defect in unit.filteredDefects{
            addLine()
            addLine(text: defect.remainingWork ? "remainingWork".localize() : "defect".localize(), type: .header3)
            addLine(label: "context".localize(), text: "defectContext".localize(param1: unit.project?.displayName ?? "", param2: unit.displayName))
            addDefectContent(defect: defect)
        }
    }
    
}

