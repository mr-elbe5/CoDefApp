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
    
    var weatherConditionField = LabeledTextInput().withTextColor(.black)
    var weatherWindLabel = LabeledText().withTextColor(.black)
    var weatherTempLabel = LabeledText().withTextColor(.black)
    var weatherHumidityLabel = LabeledText().withTextColor(.black)
    
    var briefingViews = Array<EditCompanyBriefingView>()
    
    var imageCollectionView: ImageCollectionView
    
    var commentField = LabeledTextareaInput().withTextColor(.black)
    
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
                        self.weatherWindLabel.text = "\(self.report.weatherWspd) \(self.report.weatherWdir)"
                        self.weatherTempLabel.text = self.report.weatherTemp
                        self.weatherHumidityLabel.text = self.report.weatherRhum
                    }
                }
            }
        }
    }
    
    override func setupContentView() {
        
        let nameLabel = UILabel(header: "\("dailyReport".localize()) \(report.idx) (\(report.creationDate.dateString()))").withTextColor(.black)
        contentView.addSubviewAtTop(nameLabel)
        
        weatherConditionField.setupView(labelText: "weatherConditions".localizeWithColon(), text: report.weatherCoco, inline: true)
        contentView.addSubviewAtTop(weatherConditionField, topView: nameLabel)
        
        weatherWindLabel.setupView(labelText: "wind".localizeWithColon(), text: "\(self.report.weatherWspd) \(self.report.weatherWdir)", inline: true)
        contentView.addSubviewAtTop(weatherWindLabel, topView: weatherConditionField, insets: flatInsets)
        
        weatherTempLabel.setupView(labelText: "temperature".localizeWithColon(), text: self.report.weatherTemp, inline: true)
        contentView.addSubviewAtTop(weatherTempLabel, topView: weatherWindLabel, insets: flatInsets)
        
        weatherHumidityLabel.setupView(labelText: "humidity".localizeWithColon(), text: self.report.weatherRhum, inline: true)
        contentView.addSubviewAtTop(weatherHumidityLabel, topView: weatherTempLabel, insets: flatInsets)
        
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
        
        commentField.setupView(labelText: "generalComment".localizeWithColon(), text: report.comment)
        contentView.addSubviewWithAnchors(commentField, top: imageCollectionView.bottomAnchor, leading: contentView.leadingAnchor, trailing: contentView.trailingAnchor, insets: defaultInsets)
            .bottom(contentView.bottomAnchor, inset: -keyboardInset)
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
        report.comment = commentField.text
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
    
    var selectSwitch = Checkbox().withTextColor(.black).withIconColor(.black)
    var activityField = LabeledTextareaInput().withTextColor(.black)
    var briefingField = LabeledTextareaInput().withTextColor(.black)
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
        setRoundedBorders()
        selectSwitch.setup(title: "\(company.name) \("present".localize())", isOn: present)
        selectSwitch.delegate = self
        addSubviewWithAnchors(selectSwitch, top: topAnchor, leading: leadingAnchor, insets: flatInsets)
        activityField.setupView(labelText: "activity".localizeWithColon(), text: activity)
        addSubviewWithAnchors(activityField, top: selectSwitch.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: flatInsets)
        briefingField.setupView(labelText: "briefing".localizeWithColon(), text: briefing)
        addSubviewWithAnchors(briefingField, top: activityField.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: flatInsets)
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


