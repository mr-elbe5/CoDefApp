/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class EditUnitViewController: EditViewController {
    
    var scope: UnitData
    
    var delegate: ScopeDelegate? = nil
    
    var nameField = LabeledTextInput()
    var descriptionField = LabeledTextareaInput()
    
    var planContainerView = UIView()
    
    override var infoViewController: InfoViewController?{
        EditScopeInfoViewController()
    }
    
    init(scope: UnitData){
        self.scope = scope
        super.init()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "unit".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: scope.name)
        contentView.addSubviewAtTop(nameField)
        
        descriptionField.setupView(labelText: "description".localizeWithColon(), text: scope.description)
        contentView.addSubviewAtTop(descriptionField, topView: nameField)
        
        let label = UILabel(header: "plan".localizeWithColon())
        contentView.addSubviewWithAnchors(label, top: descriptionField.bottomAnchor, leading: contentView.leadingAnchor, insets: UIEdgeInsets(top: 2*defaultInset, left: defaultInset, bottom: 0, right: 0))
        
        let addImageButton = IconButton(icon: "photo".localize(), tintColor: .systemBlue)
        addImageButton.setGrayRoundedBorders()
        contentView.addSubviewWithAnchors(addImageButton, top: descriptionField.bottomAnchor, trailing: contentView.centerXAnchor, insets: doubleInsets)
        addImageButton.addAction(UIAction(){ action in
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.allowsEditing = true
            pickerController.mediaTypes = ["public.image"]
            pickerController.sourceType = .photoLibrary
            pickerController.modalPresentationStyle = .fullScreen
            self.present(pickerController, animated: true, completion: nil)
        }, for: .touchDown)
        
        let addPhotoButton = IconButton(icon: "camera", tintColor: .systemBlue)
        addPhotoButton.setGrayRoundedBorders()
        contentView.addSubviewWithAnchors(addPhotoButton, top: descriptionField.bottomAnchor, leading: contentView.centerXAnchor, insets: doubleInsets)
        addPhotoButton.addAction(UIAction(){ action in
            AVCaptureDevice.askCameraAuthorization(){ result in
                switch result{
                case .success(()):
                    DispatchQueue.main.async {
                        let imageCaptureController = PhotoCaptureViewController()
                        imageCaptureController.modalPresentationStyle = .fullScreen
                        imageCaptureController.delegate = self
                        self.present(imageCaptureController, animated: true)
                    }
                    return
                case .failure:
                    DispatchQueue.main.async {
                        self.showAlert(title: "error".localize(), text: "cameraNotAuthorized".localize())
                    }
                    return
                }
            }
        }, for: .touchDown)
        addPhotoButton.isEnabled = AVCaptureDevice.isCameraAvailable
        
        setupPlanContainerView()
        contentView.addSubviewAtTop(planContainerView, topView: addImageButton)
            .bottom(contentView.bottomAnchor)
    }
    
    func setupPlanContainerView(){
        planContainerView.removeAllSubviews()
        if let plan = scope.plan{
            let imageView = ImageFileView(imageFile: plan)
            imageView.setAspectRatioConstraint()
            planContainerView.addSubviewFilling(imageView)
        }
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            scope.name = nameField.text
            scope.description = descriptionField.text
            if let imageView = planContainerView.subviews.first as? ImageFileView{
                if imageView.imageFile != self.scope.plan{
                    scope.setPlan(image: imageView.imageFile)
                }
            }
            if scope.isNew, let project = scope.project{
                project.scopes.append(scope)
                project.changed()
                scope.isNew = false
            }
            scope.changed()
            scope.saveData()
            delegate?.scopeChanged()
            return true
        }
        else{
            showError("mandatoryFieldsError")
        }
        return false
    }
    
    private func updatePlanImage(image: ImageFile){
        if scope.plan != nil{
            self.showDestructiveApprove(text: "planReplaceInfo".localize()){
                for issue in self.scope.defects{
                    issue.position = .zero
                    issue.planImage = nil
                }
                self.setPlanImage(image: image)
            }
        }
        else{
            setPlanImage(image: image)
        }
    }
    
    private func setPlanImage(image: ImageFile){
        scope.setPlan(image: image)
        scope.changed()
        scope.saveData()
        setupPlanContainerView()
        delegate?.scopeChanged()
    }
    
    override func deleteImageData(image: ImageFile) {
        self.scope.deletePlan()
        scope.changed()
        scope.saveData()
        self.setupPlanContainerView()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let imageURL = info[.imageURL] as? URL else {return}
        let image = ImageFile()
        image.setFileNameFromURL(imageURL)
        if FileController.copyFile(fromURL: imageURL, toURL: image.fileURL){
            updatePlanImage(image: image)
        }
        picker.dismiss(animated: false)
    }
    
    override func photoCaptured(photo: ImageFile) {
        updatePlanImage(image: photo)
    }
    
}

class EditScopeInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("unitEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText("unitEditInfoText".localize()))
    }
    
}
