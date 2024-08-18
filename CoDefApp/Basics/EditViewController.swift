/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation
import E5IOSUI

class EditViewController: ScrollViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCollectionDelegate{
    
    var infoViewController: InfoViewController?{
        nil
    }
    
    override func loadView() {
        super.loadView()
        
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "save".localize(), primaryAction: UIAction(){ action in
            if self.save(){
                self.navigationController?.popViewController(animated: true)
            }
        }))
        navigationItem.leftBarButtonItems = items
        
        items = Array<UIBarButtonItem>()
        
        if let controller = self.infoViewController{
            items.append(UIBarButtonItem(image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
                self.navigationController?.pushViewController(controller, animated: true)
            }))
        }
        items.append(UIBarButtonItem(title: "cancel".localize(), primaryAction: UIAction(){ action in
            self.navigationController?.popViewController(animated: true)
        }))
        navigationItem.rightBarButtonItems = items
        
        setupKeyboard()
    }
    
    func save() -> Bool{
        return false
    }
    
    func addImageSection(below previousAnchor: NSLayoutYAxisAnchor, imageCollectionView: ImageCollectionView){
        let label = UILabel(header: "images".localizeWithColon()).withTextColor(.black)
        contentView.addSubviewWithAnchors(label, top: previousAnchor, leading: contentView.leadingAnchor, insets: UIEdgeInsets(top: 2*defaultInset, left: defaultInset, bottom: 0, right: 0))
        
        let addImageButton = IconButton(icon: "photo".localize(),tintColor: .systemBlue, backgroundColor: .systemBackground, withBorder: true)
        addImageButton.setGrayRoundedBorders()
        contentView.addSubviewWithAnchors(addImageButton,top: label.bottomAnchor, trailing: contentView.centerXAnchor, insets: doubleInsets)
        addImageButton.addAction(UIAction(){ action in
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.allowsEditing = true
            pickerController.mediaTypes = ["public.image"]
            pickerController.sourceType = .photoLibrary
            pickerController.modalPresentationStyle = .fullScreen
            self.present(pickerController, animated: true, completion: nil)
        }, for: .touchDown)
        
        let addPhotoButton = IconButton(icon: "camera",tintColor: .systemBlue, backgroundColor: .systemBackground, withBorder: true)
        addPhotoButton.setGrayRoundedBorders()
        contentView.addSubviewWithAnchors(addPhotoButton,top: label.bottomAnchor, leading: contentView.centerXAnchor, insets: doubleInsets)
        addPhotoButton.addAction(UIAction(){ action in
            AVCaptureDevice.askCameraAuthorization(){ result in
                switch result{
                case .success(()):
                    DispatchQueue.main.async {
                        let pickerController = UIImagePickerController()
                        pickerController.delegate = self
                        pickerController.sourceType = .camera
                        pickerController.modalPresentationStyle = .fullScreen
                        self.present(pickerController, animated: true, completion: nil)
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
        
        let addLabel = UILabel(text: "add".localizeWithColon()).withTextColor(.black)
        contentView.addSubviewWithAnchors(addLabel, leading: contentView.leadingAnchor, insets: defaultInsets)
            .centerY(addImageButton.centerYAnchor)
        
        imageCollectionView.imageDelegate = self
        contentView.addSubviewAtTop(imageCollectionView, topView: addLabel)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var success = false
        if picker.sourceType == .camera{
            if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                let image = ImageData()
                image.setJpegFileName()
                while FileManager.default.fileExists(url: FileManager.fileDirURL.appendingPathComponent(image.fileName)){
                    image.id = AppState.shared.nextId
                    image.setJpegFileName()
                }
                if image.saveJpegImage(uiImage: img){
                    imagePicked(image: image)
                    success = true
                }
            }
        }
        else{
            guard let imageURL = info[.imageURL] as? URL else {return}
            let image = ImageData()
            image.setFileNameFromURL(imageURL)
            if FileManager.default.copyFile(fromURL: imageURL, toURL: image.fileURL){
                imagePicked(image: image)
                success = true
            }
        }
        picker.dismiss(animated: false)
        if !success{
            showAlert(title: "error", text: "imageNotSaved")
        }
    }
    
    func imagePicked(image: ImageData){
    }
    
}


