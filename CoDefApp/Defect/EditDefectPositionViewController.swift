/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class EditDefectPositionViewController: ImageViewController {
    
    var defect = DefectData()
    
    var marker: DefectMarkerButton
    
    var positionDelegate: DefectPositionDelegate? = nil
    
    init(defect: DefectData, plan: ImageFile){
        self.defect.position = defect.position
        marker = DefectMarkerButton(defect: self.defect)
        super.init(imageFile: plan, fitImage: false)
    }
    
    override func setupNavigationBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "accept".localize(), primaryAction: UIAction(){ action in
            self.positionDelegate?.positionChanged(position: self.defect.position)
            self.navigationController?.popViewController(animated: true)
        })
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "cancel".localize(), primaryAction: UIAction(){ action in
            self.navigationController?.popViewController(animated: true)
        }))
        items.append(UIBarButtonItem(image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = PositionInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "selectPosition".localize()
        super.loadView()
    }
    
    override func setupScrollView(){
        super.setupScrollView()
        scrollView.imageView.addSubview(marker)
        marker.updateFrame(in: scrollView.contentSize)
        marker.updateVisibility()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action:  #selector (onTouch))
        scrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func onTouch(_ sender: UIGestureRecognizer){
        marker.moveTo(pnt: sender.location(in: scrollView.imageView))
        marker.updateDefect(in: imageFile.getImage().size)
        marker.updateVisibility()
    }
    
}

class PositionInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("issuePositionInfoHeader".localize()))
        block.addArrangedSubview(InfoText("issuePositionInfoText".localize()))
    }
    
}
