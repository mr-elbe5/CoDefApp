/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class EditDailyReportViewController: EditViewController {
    
    var report: DailyReport
    
    var delegate: DailyReportDelegate? = nil
    
    var weatherConditionField = LabeledTextInput()
    var weatherWindLabel = LabeledText()
    var weatherTempLabel = LabeledText()
    var weatherHumidityLabel = LabeledText()
    
    var briefingViews = Array<EditCompanyBriefingView>()
    
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
        if report.weatherCoco.isEmpty{
            Task{
                if let weatherData = try await report.project.getWeatherData(){
                    DispatchQueue.main.async{
                        self.report.setWeatherData(from: weatherData)
                        self.weatherConditionField.text = self.report.weatherCoco
                        self.weatherWindLabel.text = "\(self.report.weatherWspd) km/h \(self.report.weatherWdir)"
                        self.weatherTempLabel.text = "\(self.report.weatherTemp) °C"
                        self.weatherHumidityLabel.text = "\(self.report.weatherRhum) %"
                    }
                }
            }
        }
    }
    
    override func setupContentView() {
        
        let nameLabel = UILabel(header: "\("dailyReport".localize()) \(report.idx) (\(report.creationDate.dateString()))")
        contentView.addSubviewAtTop(nameLabel)
        
        weatherConditionField.setupView(labelText: "weatherConditions".localizeWithColon(), text: report.weatherCoco, inline: true)
        contentView.addSubviewAtTop(weatherConditionField, topView: nameLabel)
        
        weatherWindLabel.setupView(labelText: "wind".localizeWithColon(), text: "\(self.report.weatherWspd) km/h \(self.report.weatherWdir)", inline: true)
        contentView.addSubviewAtTop(weatherWindLabel, topView: weatherConditionField, insets: horizontalInsets)
        
        weatherTempLabel.setupView(labelText: "temperature".localizeWithColon(), text: "\(self.report.weatherTemp) °C", inline: true)
        contentView.addSubviewAtTop(weatherTempLabel, topView: weatherWindLabel, insets: horizontalInsets)
        
        weatherHumidityLabel.setupView(labelText: "humidity".localizeWithColon(), text: "\(self.report.weatherRhum) %", inline: true)
        contentView.addSubviewAtTop(weatherHumidityLabel, topView: weatherTempLabel, insets: horizontalInsets)
        
        var lastView : UIView = weatherHumidityLabel
        
        for company in report.projectCompanies{
            let briefing = report.getBriefing(company: company)
            let briefingView =  EditCompanyBriefingView(company: company)
            briefingView.setupView(present: briefing != nil, activity: briefing?.activity ?? "", briefing: briefing?.briefing ?? "")
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
        report.weatherCoco = weatherConditionField.text
        report.companyBriefings.removeAll()
        for briefingView in briefingViews {
            if briefingView.selectSwitch.isOn{
                let briefing = CompanyBriefing()
                briefing.companyId = briefingView.company.id
                briefing.activity = briefingView.activityField.text
                briefing.briefing = briefingView.briefingField.text
                report.companyBriefings.append(briefing)
            }
        }
        report.project.addDailyReport(report)
        delegate?.dailyReportChanged()
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

class EditCompanyBriefingView: UIView{
    
    var company: CompanyData
    
    var selectSwitch = Checkbox()
    var activityField = LabeledTextareaInput()
    var briefingField = LabeledTextareaInput()
    var activityConstraint: NSLayoutConstraint!
    var briefingConstraint:NSLayoutConstraint!
    
    init(company: CompanyData){
        self.company = company
        selectSwitch.title = company.name
        super.init(frame: .zero)
        activityConstraint = activityField.heightAnchor.constraint(equalToConstant: 0)
        briefingConstraint = briefingField.heightAnchor.constraint(equalToConstant: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(present: Bool = false, activity: String = "", briefing: String = ""){
        backgroundColor = .white
        setRoundedBorders()
        selectSwitch.setup(title: "\(company.name) \("present".localize())", isOn: present)
        selectSwitch.delegate = self
        addSubviewWithAnchors(selectSwitch, top: topAnchor, leading: leadingAnchor, insets: horizontalInsets)
        activityField.setupView(labelText: "activity".localizeWithColon(), text: activity)
        addSubviewWithAnchors(activityField, top: selectSwitch.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: horizontalInsets)
        briefingField.setupView(labelText: "briefing".localizeWithColon(), text: briefing)
        addSubviewWithAnchors(briefingField, top: activityField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: horizontalInsets)
            .bottom(bottomAnchor, inset: -defaultInset)
        updateVisibility()
    }
    
    func updateVisibility(){
        self.activityField.isHidden = !selectSwitch.isOn
        activityConstraint.isActive = !selectSwitch.isOn
        self.briefingField.isHidden = !selectSwitch.isOn
        briefingConstraint.isActive = !selectSwitch.isOn
        setNeedsLayout()
    }
}

extension EditCompanyBriefingView: CheckboxDelegate{
    
    func checkboxIsSelected(index: Int, value: String) {
        updateVisibility()
    }
    
}


