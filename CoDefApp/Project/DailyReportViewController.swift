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
    
    var descriptionField = LabeledTextareaInput()
    var positionCommentField = LabeledTextareaInput()
    var remainingWorkField = LabeledCheckbox()
    var notifiedField = LabeledCheckbox()
    var phaseField = LabeledPhaseSelectField()
    var statusField = LabeledDefectStatusSelectView()
    var assignField = LabeledCompanySelectField()
    var dueDateField = LabeledDatePicker()
    
    
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
    }
    
    override func setupContentView() {
        
        
        
        //addImageSection(below: lastView.bottomAnchor, imageCollectionView: imageCollectionView)
        
    }
    
    override func deleteImageData(image: ImageData) {
        report.images.remove(obj: image)
        report.changed()
        report.saveData()
        imageCollectionView.images.remove(obj: image)
        imageCollectionView.reloadData()
    }
    
    override func save() -> Bool{
        if !descriptionField.text.isEmpty {
            
            report.changed()
            report.saveData()
            delegate?.dailyReportChanged()
            return true
        }
        else{
            showError("mandatoryFieldsError")
        }
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

