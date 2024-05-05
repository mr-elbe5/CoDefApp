/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class DailyReportViewController: ScrollViewController {
    
    var report: DailyReport
    
    var weatherConditionLabel = LabeledText()
    var weatherWindLabel = LabeledText()
    var weatherTempLabel = LabeledText()
    var weatherHumidityLabel = LabeledText()
    
    var imageCollectionView: ImageCollectionView
    
    init(report: DailyReport){
        self.report = report
        imageCollectionView = ImageCollectionView(images: self.report.images, enableDelete: true)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = report.displayName
        modalPresentationStyle = .fullScreen
        super.loadView()
    }
    
    override func setupContentView() {
        
        let nameLabel = UILabel(header: "\("dailyReport".localize()) \(report.idx) (\(report.creationDate.dateString()))")
        contentView.addSubviewAtTop(nameLabel)
        
        let view = UIView()
        view.backgroundColor = .white
        view.setRoundedBorders()
        
        view.addSubviewAtTop(weatherConditionLabel)
        weatherConditionLabel.setupView(labelText: "weatherConditions".localizeWithColon(), text: report.weatherCoco, inline: true)
        view.addSubviewAtTop(weatherWindLabel, topView: weatherConditionLabel, insets: horizontalInsets)
        weatherWindLabel.setupView(labelText: "wind".localizeWithColon(), text: "\(self.report.weatherWspd) km/h \(report.weatherWdir)", inline: true)
        view.addSubviewAtTop(weatherWindLabel, topView: weatherConditionLabel, insets: horizontalInsets)
        weatherTempLabel.setupView(labelText: "temperature".localizeWithColon(), text: "\(report.weatherTemp) °C", inline: true)
        view.addSubviewAtTop(weatherTempLabel, topView: weatherWindLabel, insets: horizontalInsets)
        weatherHumidityLabel.setupView(labelText: "humidity".localizeWithColon(), text: "\(report.weatherRhum) %", inline: true)
        view.addSubviewAtTop(weatherHumidityLabel, topView: weatherTempLabel, insets: horizontalInsets)
            .bottom(view.bottomAnchor)
        
        contentView.addSubviewAtTop(view, topView: nameLabel, insets: defaultInsets)
        
        let presentLabel = UILabel(header: "present".localizeWithColon())
        contentView.addSubviewAtTop(presentLabel, topView: view, insets: defaultInsets)
        
        var lastView : UIView = presentLabel
        
        for briefing in report.companyBriefings{
            let view = UIView()
            view.backgroundColor = .white
            view.setRoundedBorders()
            let nameLabel = UILabel(header: report.projectCompany(id: briefing.companyId)?.name ?? "n/n")
            view.addSubviewAtTop(nameLabel, insets: defaultInsets)
            let activityLabel = LabeledText()
            activityLabel.setupView(labelText: "activity".localizeWithColon(), text: briefing.activity, inline: true)
            view.addSubviewAtTop(activityLabel, topView: nameLabel, insets: horizontalInsets)
            let briefingLabel = LabeledText()
            briefingLabel.setupView(labelText: "briefing".localizeWithColon(), text: briefing.briefing, inline: true)
            view.addSubviewAtTop(briefingLabel, topView: activityLabel, insets: horizontalInsets)
                .bottom(view.bottomAnchor)
            contentView.addSubviewAtTop(view, topView: lastView, insets: defaultInsets)
            lastView = view
        }
        
        let imageCollectionView = ImageCollectionView(images: report.images, enableDelete: false)
        contentView.addSubviewAtTop(imageCollectionView, topView: lastView, insets: defaultInsets)
            .bottom(contentView.bottomAnchor)
        
    }
    
}


