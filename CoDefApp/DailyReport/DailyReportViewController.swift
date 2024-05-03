/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class DailyReportViewController: EditViewController {
    
    var report: ProjectDailyReport
    
    var delegate: DailyReportDelegate? = nil
    
    var weatherConditionLabel = LabeledText()
    var weatherWindLabel = LabeledText()
    var weatherTempLabel = LabeledText()
    var weatherHumidityLabel = LabeledText()
    
    var planView : UnitPlanView? = nil
    
    var imageCollectionView: ImageCollectionView
    
    override var infoViewController: InfoViewController?{
        EditDefectInfoViewController()
    }
    
    init(report: ProjectDailyReport){
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
        
        addImageSection(below: weatherHumidityLabel.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        report.images.remove(obj: image)
        report.changed()
        report.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        
        return false
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

class DailyReportInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("dailyReportInfoHeader".localize()))
        block.addArrangedSubview(InfoText("dailyReportInfoText".localize()))
    }
    
}

