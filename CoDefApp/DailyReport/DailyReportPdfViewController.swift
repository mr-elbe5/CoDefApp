/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class DailyReportPdfViewController: PDFViewController {
    
    var report: DailyReport
    
    init(report: DailyReport){
        self.report = report
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "\("pdf".localize()) \("for".localize()) \(report.displayName)"
        super.loadView()
        
    }
    
    override func createPDF() -> Data{
        pdfCreator.createDefectPDF(report: report)
    }
    
}

extension PDFRenderer {
    
    func createDefectPDF(report: DailyReport) -> Data{
        let pdfMetaData = [
            kCGPDFContextCreator: "Construction Defect Tracker",
            kCGPDFContextTitle: report.displayName
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            self.context = context
            context.beginPage()
            start(title: "dailyReport".localize())
            addReportContent(report: report)
        }
        return data
    }
    
    func addReportContent(report: DailyReport){
        addLine(label: "name".localize(), text: report.displayName)
        addLine(label: "location".localize(), text: report.project.address)
        addLine(label: "reportNumber".localize(), text: String(report.idx))
        addLine(label: "creationDate".localize(), text: report.creationDate.asString())
        addLine(label: "creator".localize(), text: report.creatorName)
        addSpacer()
        addLine(label: "weatherConditions".localize(), text: report.weatherCoco)
        addLine(label: "wind".localize(), text: "\(report.weatherWspd) \(report.weatherWdir)")
        addLine(label: "temperature".localize(), text: report.weatherTemp)
        addLine(label: "humidity".localize(), text: report.weatherRhum)
        addSpacer()
        for briefing in report.companyBriefings{
            addSpacer()
            addLine(text: report.projectCompany(id: briefing.companyId)?.name ?? "n/n", type: .header3)
            addLine(label: "activity".localize(), text: briefing.activity)
            addLine(label: "briefing".localize(), text: briefing.briefing)
        }
        addSpacer()
        if !report.images.isEmpty{
            addLine(label: "images".localize(), text: "")
            addLine(label: "", images: report.images, maxHeight: pageRect.height * 0.2)
        }
    }
    
}
