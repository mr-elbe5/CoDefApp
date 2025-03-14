/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class DailyReportViewController: ScrollViewController {
    
    var report: DailyReport
    
    var weatherConditionLabel = LabeledText().withTextColor(.black)
    var weatherWindLabel = LabeledText().withTextColor(.black)
    var weatherTempLabel = LabeledText().withTextColor(.black)
    var weatherHumidityLabel = LabeledText().withTextColor(.black)
    
    var imageCollectionView: ImageCollectionView
    
    var delegate: DailyReportDelegate? = nil
    
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
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "report".localize(), image: UIImage(systemName: "doc.text"), primaryAction: UIAction(){ action in
            let controller = DailyReportPdfViewController(report: self.report)
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        if AppState.shared.standalone || !report.isOnServer{
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditDailyReportViewController(report: self.report)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), primaryAction: UIAction(){ action in
            if let project = self.report.project{
                self.showDestructiveApprove(title: "delete".localize(), text: "deleteInfo".localize(), onApprove: {
                    project.removeDailyReport(self.report)
                    project.changed()
                    project.saveData()
                    self.delegate?.dailyReportChanged()
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView() {
        
        let nameLabel = UILabel(header: "\("dailyReport".localize()) \(report.idx) (\(report.creationDate.dateString()))").withTextColor(.black)
        contentView.addSubviewAtTop(nameLabel)
        
        var view = UIView()
        view.backgroundColor = .white
        view.setRoundedBorders()
        
        view.addSubviewAtTop(weatherConditionLabel)
        weatherConditionLabel.setupView(labelText: "weatherConditions".localizeWithColon(), text: report.weatherCoco, inline: true)
        view.addSubviewAtTop(weatherWindLabel, topView: weatherConditionLabel, insets: flatInsets)
        weatherWindLabel.setupView(labelText: "wind".localizeWithColon(), text: "\(self.report.weatherWspd) \(report.weatherWdir)", inline: true)
        view.addSubviewAtTop(weatherWindLabel, topView: weatherConditionLabel, insets: flatInsets)
        weatherTempLabel.setupView(labelText: "temperature".localizeWithColon(), text: report.weatherTemp, inline: true)
        view.addSubviewAtTop(weatherTempLabel, topView: weatherWindLabel, insets: flatInsets)
        weatherHumidityLabel.setupView(labelText: "humidity".localizeWithColon(), text: report.weatherRhum, inline: true)
        view.addSubviewAtTop(weatherHumidityLabel, topView: weatherTempLabel, insets: flatInsets)
            .bottom(view.bottomAnchor)
        
        contentView.addSubviewAtTop(view, topView: nameLabel, insets: defaultInsets)
        
        let presentLabel = UILabel(header: "present".localizeWithColon()).withTextColor(.black)
        contentView.addSubviewAtTop(presentLabel, topView: view, insets: defaultInsets)
        
        var lastView : UIView = presentLabel
        
        for briefing in report.companyBriefings{
            let view = UIView()
            view.backgroundColor = .white
            view.setRoundedBorders()
            let nameLabel = UILabel(header: report.projectCompany(id: briefing.companyId)?.name ?? "n/n").withTextColor(.black)
            view.addSubviewAtTop(nameLabel, insets: defaultInsets)
            let activityLabel = LabeledText()
            activityLabel.setupView(labelText: "activity".localizeWithColon(), text: briefing.activity, inline: true)
            view.addSubviewAtTop(activityLabel, topView: nameLabel, insets: flatInsets)
            let briefingLabel = LabeledText()
            briefingLabel.setupView(labelText: "briefing".localizeWithColon(), text: briefing.briefing, inline: true)
            view.addSubviewAtTop(briefingLabel, topView: activityLabel, insets: flatInsets)
                .bottom(view.bottomAnchor)
            contentView.addSubviewAtTop(view, topView: lastView, insets: defaultInsets)
            lastView = view
        }
        
        let imageCollectionView = ImageCollectionView(images: report.images, enableDelete: false)
        contentView.addSubviewAtTop(imageCollectionView, topView: lastView, insets: defaultInsets)
        
        if !report.comment.isEmpty{
            let label = UILabel(header: "generalComment".localizeWithColon())
            contentView.addSubviewAtTop(label, topView: imageCollectionView, insets: defaultInsets)
            view = UIView()
            view.backgroundColor = .white
            view.setRoundedBorders()
            contentView.addSubviewAtTop(view, topView: label, insets: defaultInsets)
                .bottom(contentView.bottomAnchor, inset: -defaultInset)
            let textLabel = UILabel(text: report.comment)
            view.addSubviewFilling(textLabel, insets: defaultInsets)
        }
        else{
            imageCollectionView.bottom(contentView.bottomAnchor)
        }
        
    }
    
}

extension DailyReportViewController: DailyReportDelegate{
    
    func dailyReportChanged() {
        contentView.removeAllSubviews()
        setupContentView()
    }
    
    func dailyReportDeleted() {
    }
    
}

