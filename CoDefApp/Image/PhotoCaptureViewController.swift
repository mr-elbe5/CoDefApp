/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import AVFoundation
import Photos


protocol PhotoCaptureDelegate{
    func photoCaptured(photo: ImageFile)
}

class PhotoCaptureViewController: CameraViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var flashMode : AVCaptureDevice.FlashMode = .auto
    
    var delegate: PhotoCaptureDelegate? = nil
    
    private let photoOutput = AVCapturePhotoOutput()
    
    override func addCameraButtons(){
        
        cameraButton.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        cameraButton.addAction(UIAction(){ action in
            self.changeCamera()
        }, for: .touchDown)
        cameraButtonContainerView.addSubviewWithAnchors(cameraButton, top: cameraButtonContainerView.topAnchor, leading: cameraButtonContainerView.leadingAnchor, bottom: cameraButtonContainerView.bottomAnchor, insets: defaultInsets)
        
        flashButton.setImage(UIImage(systemName: "bolt.badge.a"), for: .normal)
        flashButton.addAction(UIAction(){ action in
            switch self.flashMode{
            case .auto:
                self.flashMode = .on
                self.flashButton.setImage(UIImage(systemName: "bolt"), for: .normal)
                break
            case .on:
                self.flashMode = .off
                self.flashButton.setImage(UIImage(systemName: "bolt.slash"), for: .normal)
                break
            default:
                self.flashMode = .auto
                self.flashButton.setImage(UIImage(systemName: "bolt.badge.a"), for: .normal)
                break
            }
        }, for: .touchDown)
        cameraButtonContainerView.addSubviewWithAnchors(flashButton, top: cameraButtonContainerView.topAnchor, leading: cameraButton.trailingAnchor, trailing: cameraButtonContainerView.trailingAnchor, bottom: cameraButtonContainerView.bottomAnchor, insets: UIEdgeInsets(top: defaultInset, left: 2*defaultInset, bottom: defaultInset, right: defaultInset))
        let isFlashAvailable = AVCaptureDevice.defaultCameraDevice?.isFlashAvailable ?? false
        flashButton.isEnabled = isFlashAvailable
        if !isFlashAvailable{
            flashMode = .off
        }
        
        captureButton.addAction(UIAction(){ action in
            let videoPreviewLayerOrientation = self.preview.videoPreviewLayer.connection?.videoOrientation
            
            self.sessionQueue.async {
                if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                    photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
                }
                var photoSettings = AVCapturePhotoSettings()
                if  self.photoOutput.availablePhotoCodecTypes.contains(.jpeg) {
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                }
                if self.videoDeviceInput.device.isFlashAvailable {
                    photoSettings.flashMode = self.flashMode
                }
                //photoSettings.maxPhotoDimensions =
                
                if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
                    photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
                }
                photoSettings.isDepthDataDeliveryEnabled = false
                photoSettings.photoQualityPrioritization = .quality
                // shutter animation
                DispatchQueue.main.async {
                    self.preview.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) {
                        self.preview.videoPreviewLayer.opacity = 1
                    }
                }
                self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        }, for: .touchDown)
        bodyView.addSubviewWithAnchors(captureButton, bottom: bodyView.bottomAnchor, insets: defaultInsets)
            .centerX(bodyView.centerXAnchor)
            .width(50)
            .height(50)
        
    }
    
    override func enableCameraButtons(flag: Bool){
        captureButton.isEnabled = flag
        cameraButton.isEnabled = flag
    }
    
    func configurePhoto(){
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            //photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = false
            photoOutput.isDepthDataDeliveryEnabled = false
            photoOutput.isPortraitEffectsMatteDeliveryEnabled = false
            photoOutput.enabledSemanticSegmentationMatteTypes = []
            photoOutput.maxPhotoQualityPrioritization = .quality
            
        } else {
            Log.error("PhotoCaptureViewController Could not add photo output to the session")
            isInputAvailable = false
            session.commitConfiguration()
            return
        }
    }
    
    override func configureSession(){
        isInputAvailable = true
        session.beginConfiguration()
        session.sessionPreset = .photo
        configureVideo()
        if !isInputAvailable{
            return
        }
        configurePhoto()
        if !isInputAvailable {
            return
        }
        session.commitConfiguration()
    }
    
    override func replaceVideoDevice(newVideoDevice videoDevice: AVCaptureDevice){
        let currentVideoDevice = self.videoDeviceInput.device
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            self.session.beginConfiguration()
            
            self.session.removeInput(self.videoDeviceInput)
            
            if self.session.canAddInput(videoDeviceInput) {
                NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.session.addInput(self.videoDeviceInput)
            }
            
            self.photoOutput.maxPhotoQualityPrioritization = .quality
            
            self.session.commitConfiguration()
            
        } catch let err{
            Log.error("PhotoCaptureViewController Error occurred while creating video device input: \(err)")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            Log.error(msg: "PhotoCaptureViewController capturing photo", error: error)
        } else {
            if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData){
                let acceptController = PhotoAcceptViewController(imageData: image)
                acceptController.modalPresentationStyle = .fullScreen
                acceptController.delegate = self
                present(acceptController, animated: true)
            }
        }
    }
    
    override func addObservers(){
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                self.captureButton.isEnabled = isSessionRunning
            }
        }
        keyValueObservations.append(keyValueObservation)
        super.addObservers()
    }
    
}

extension PhotoCaptureViewController: PhotoAcceptDelegate{
    
    func photoAccepted(imageData: UIImage) {
        let image = ImageFile()
        image.setJpegFileName()
        image.saveImage(uiImage: imageData)
        dismiss(animated: false){
            self.delegate?.photoCaptured(photo: image)
        }
    }
    
    func photoDismissed() {
        //Log.debug("PhotoCaptureViewController photo dismissed")
    }
    
    
}

protocol PhotoAcceptDelegate{
    func photoAccepted(imageData: UIImage)
    func photoDismissed()
}

class PhotoAcceptViewController: ModalViewController{
    
    var imageData : UIImage
    
    var delegate: PhotoAcceptDelegate? = nil
    
    init(imageData: UIImage){
        self.imageData = imageData
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupContentView() {
        contentView.backgroundColor = .black
        let imageView = UIImageView(image: imageData)
        imageView.setDefaults()
        imageView.image = imageData
        contentView.addSubviewFilling(imageView)
    }
    
    override func setupMenu() {
        menuView.backgroundColor = .black
        let cancelButton = TextButton(text: "cancel".localize())
        cancelButton.addAction(UIAction(){ action in
            self.dismiss(animated: false)
        }, for: .touchDown)
        menuView.addSubviewWithAnchors(cancelButton, top: menuView.topAnchor, trailing: menuView.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
        let acceptButton = TextButton(text: "accept".localize())
        acceptButton.addAction(UIAction(){ action in
            self.dismiss(animated: false){
                self.delegate?.photoAccepted(imageData: self.imageData)
            }
        }, for: .touchDown)
        menuView.addSubviewWithAnchors(acceptButton, top: menuView.topAnchor, leading: menuView.leadingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
    }
    
}
