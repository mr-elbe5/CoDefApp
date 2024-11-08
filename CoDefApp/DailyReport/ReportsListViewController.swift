/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class ReportsListViewController: ScrollViewController {
    
    var project: ProjectData
    
    init(project: ProjectData){
        self.project = project
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = project.displayName
        super.loadView()
    }
    
    override func setupContentView(){
        let headerLabel = UILabel(header: "dailyReports".localizeWithColon()).withTextColor(.black)
        contentView.addSubviewAtTop(headerLabel, insets: defaultInsets)
        var lastView: UIView = headerLabel
        for report in project.dailyReports{
            let sectionLine = getReportSectionLine(report: report)
            contentView.addSubviewAtTop(sectionLine, topView: lastView, insets: defaultInsets)
            lastView = sectionLine
        }
        lastView.bottom(contentView.bottomAnchor)
    }
    
    func getReportSectionLine(report: DailyReport) -> UIView{
        let line = SectionLine(name: report.displayName, action: UIAction(){action in
            let controller = DailyReportViewController(report: report)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        })
        return line
    }
}

extension ReportsListViewController: DailyReportDelegate{
    
    func dailyReportChanged() {
        contentView.removeAllSubviews()
        setupContentView()
    }
    
}
