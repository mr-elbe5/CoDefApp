/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class DefectPdfViewController: PDFViewController {
    
    var defect: DefectData
    
    init(defect: DefectData){
        self.defect = defect
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "\("pdf".localize()) \("for".localize()) \(defect.name)"
        super.loadView()
        
    }
    
    override func createPDF() -> Data{
        pdfCreator.createDefectPDF(defect: defect)
    }
    
}

extension PDFRenderer {
    
    func createDefectPDF(defect: DefectData) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Construction Defect Tracker",
            kCGPDFContextTitle: defect.name
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "defectReport".localize())
            addDefectContent(defect: defect)
        }
        return data
    }
    
    func addDefectContent(defect: DefectData){
        addLine(label: "name".localize(), text: defect.name)
        addLine(label: "id".localize(), text: String(defect.displayId))
        if !defect.description.isEmpty{
            addLine(label: "description".localize(), text: defect.description)
        }
        addLine(label: "creator".localize(), text: defect.creatorName)
        addLine(label: "creationDate".localize(), text: defect.creationDate.dateString())
        addLine(label: "status".localize(), text: defect.status.rawValue.localize())
        addLine(label: "assignedTo".localize(), text: defect.assignedCompanyName)
        addLine(label: "dueDate".localize(), text: defect.dueDate.dateTimeString())
        defect.assertPlanImage()
        if let img = defect.planImage{
            addLine(label: "position".localize(), image: img, maxHeight: pageRect.height * 0.2)
        }
        addSpacer()
        if !defect.images.isEmpty{
            addLine(label: "images".localize(), text: "")
            addLine(label: "", images: defect.images, maxHeight: pageRect.height * 0.2)
        }
        addSpacer()
        for statusChange in defect.statusChanges{
            addLine()
            addLine(text: "statusChange".localize(), type: .header3)
            addLine(label: "context".localize(), text: "statusChangeContext".localize(param1: defect.unit?.project?.name ?? "", param2: defect.unit?.name ?? "", param3: defect.name))
            addStatusChangeContent(statusChange: statusChange)
        }
    }
    
    func addStatusChangeContent(statusChange: StatusChangeData){
        addLine(label: "on".localize(), text: statusChange.creationDate.dateTimeString())
        addLine(label: "previousAssignment".localize(), text: statusChange.previousAssignedCompanyName)
        addLine(label: "comment".localize(), text: statusChange.comment)
        
        addLine(label: "status".localize(), text: statusChange.status.rawValue.localize())
        addLine(label: "newAssignment".localize(), text: statusChange.assignedCompanyName)
        if !statusChange.images.isEmpty{
            addLine(label: "images".localize(), text: "")
            addLine(label: "", images: statusChange.images, maxHeight: pageRect.height * 0.2)
        }
    }
    
}
