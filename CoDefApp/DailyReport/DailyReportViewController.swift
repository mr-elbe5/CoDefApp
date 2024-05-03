/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class DailyReportViewController: EditViewController {
    
    var report: DailyReport
    
    var delegate: DailyReportDelegate? = nil
    
    var weatherConditionLabel = LabeledText()
    var weatherWindLabel = LabeledText()
    var weatherTempLabel = LabeledText()
    var weatherHumidityLabel = LabeledText()
    
    var briefingViews = Array<CompanyBriefingView>()
    
    var imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        EditDefectInfoViewController()
    }
    
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
        Task{
            if let weatherData = try await report.project.getWeatherData(){
                DispatchQueue.main.async{
                    self.report.setWeatherData(from: weatherData)
                    self.weatherConditionLabel.text = self.report.weatherCoco
                    self.weatherWindLabel.text = "\(self.report.weatherWspd) km/h \(self.report.weatherWdir)"
                    self.weatherTempLabel.text = "\(self.report.weatherTemp) °C"
                    self.weatherHumidityLabel.text = "\(self.report.weatherRhum) %"
                }
            }
        }
    }
    
    override func setupContentView() {
        
        let nameLabel = UILabel(header: "\("dailyReport".localize()) \(report.idx) (\(report.creationDate.dateString()))")
        contentView.addSubviewAtTop(nameLabel)
        contentView.addSubviewAtTop(weatherConditionLabel, topView: nameLabel)
        
        weatherConditionLabel.setupView(labelText: "weatherConditions".localizeWithColon(), text: "", inline: true)
        contentView.addSubviewAtTop(weatherWindLabel, topView: weatherConditionLabel, insets: horizontalInsets)
        
        weatherWindLabel.setupView(labelText: "wind".localizeWithColon(), text: "", inline: true)
        contentView.addSubviewAtTop(weatherWindLabel, topView: weatherConditionLabel, insets: horizontalInsets)
        
        weatherTempLabel.setupView(labelText: "temperature".localizeWithColon(), text: "", inline: true)
        contentView.addSubviewAtTop(weatherTempLabel, topView: weatherWindLabel, insets: horizontalInsets)
        
        weatherHumidityLabel.setupView(labelText: "humidity".localizeWithColon(), text: "", inline: true)
        contentView.addSubviewAtTop(weatherHumidityLabel, topView: weatherTempLabel, insets: horizontalInsets)
        
        var lastView : UIView = weatherHumidityLabel
        
        for company in report.projectCompanies{
            let briefingView = CompanyBriefingView(company: company)
            briefingView.setupView()
            briefingViews.append(briefingView)
            contentView.addSubviewAtTop(briefingView, topView: lastView)
            lastView = briefingView
        }
        
        addImageSection(below: lastView.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        report.images.remove(obj: image)
        report.changed()
        report.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        report .companyBriefings.removeAll()
        for briefingView in briefingViews {
            if briefingView.selectSwitch.isOn{
                let briefing = CompanyBriefing()
                briefing.companyId = briefingView.company.id
                briefing.activity = briefingView.activityField.text
                briefing.briefing = briefingView.briefingField.text
                report.companyBriefings.append(briefing)
            }
        }
        return true
    }
    
    override func imagePicked(image: ImageData) {
        report.images.append(image)
        imageCollectionView.images.append(image)
        report.changed()
        report.saveData()
        imageCollectionView.updateHeightConstraint()
        imageCollectionView.reloadData()
    }
    
}

class CompanyBriefingView: UIView{
    
    var company: CompanyData
    
    var selectSwitch = Checkbox()
    var activityField = LabeledTextareaInput()
    var briefingField = LabeledTextareaInput()
    
    init(company: CompanyData, present: Bool = false, activity: String = "", briefing: String = ""){
        self.company = company
        selectSwitch.isOn = present
        selectSwitch.title = company.name
        activityField.text = activity
        briefingField.text = briefing
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        selectSwitch.delegate = self
        addSubviewWithAnchors(selectSwitch, top: topAnchor, leading: leadingAnchor, insets: horizontalInsets)
        activityField.setupView(labelText: "activity".localizeWithColon())
        addSubviewWithAnchors(activityField, top: selectSwitch.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: horizontalInsets)
        briefingField.setupView(labelText: "briefing".localizeWithColon())
        addSubviewWithAnchors(briefingField, top: activityField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: horizontalInsets)
            .bottom(bottomAnchor)
        updateVisibility()
    }
    
    func updateVisibility(){
        self.activityField.isHidden = !selectSwitch.isOn
        self.briefingField.isHidden = !selectSwitch.isOn
    }
}

extension CompanyBriefingView: CheckboxDelegate{
    
    func checkboxIsSelected(index: Int, value: String) {
        updateVisibility()
    }
    
}

class DailyReportInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("dailyReportInfoHeader".localize()))
        block.addArrangedSubview(InfoText("dailyReportInfoText".localize()))
    }
    
}

