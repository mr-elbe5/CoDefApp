/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import AVFoundation

class EditViewController: ScrollViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoCaptureDelegate, ImageCollectionDelegate{
    
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
        items.append(UIBarButtonItem(image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            if let controller = self.infoViewController{
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }))
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
        let label = UILabel(header: "images".localizeWithColon())
        contentView.addSubviewWithAnchors(label, top: previousAnchor, leading: contentView.leadingAnchor, insets: UIEdgeInsets(top: 2*defaultInset, left: defaultInset, bottom: 0, right: 0))
        
        let addImageButton = IconButton(icon: "photo".localize(),tintColor: .systemBlue, backgroundColor: .systemBackground, withBorder: true)
        addImageButton.setGrayRoundedBorders()
        contentView.addSubviewWithAnchors(addImageButton, trailing: contentView.centerXAnchor, insets: doubleInsets)
            .centerY(label.centerYAnchor)
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
        contentView.addSubviewWithAnchors(addPhotoButton, leading: contentView.centerXAnchor, insets: doubleInsets)
            .centerY(label.centerYAnchor)
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
        
        let addLabel = UILabel(text: "add".localizeWithColon())
        contentView.addSubviewWithAnchors(addLabel, top: previousAnchor, trailing: addImageButton.leadingAnchor, insets: doubleInsets)
        
        imageCollectionView.imageDelegate = self
        contentView.addSubviewAtTop(imageCollectionView, topView: addImageButton)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        
    }
    
    func photoCaptured(photo: ImageData) {
    }
    
}


