/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class BaseViewController: UIViewController {
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .systemBackground
    }
    
    func deleteImageData(image: ImageData){
    }
    
    func shareImage(image: ImageData) {
        let alertController = UIAlertController(title: title, message: "shareImage".localize(), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "imageLibrary".localize(), style: .default) { action in
            Task{
                if await FileController.copyImageToLibrary(name: image.fileName, fromDir: FileController.privateURL){
                    self.showAlert(title: "success".localize(), text: "imageShared".localize())
                }
                else{
                    self.showAlert(title: "error".localize(), text: "todo")
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
}

extension BaseViewController: ImageFileViewDelegate{
    
    func viewImage(image: ImageData, imageDeleteDelegate: ImageFileDeleteDelegate? = nil ) {
        let controller = ImageViewController(imageFile: image)
        controller.deleteDelegate = imageDeleteDelegate
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension BaseViewController: ImageFileDeleteDelegate{
    
    func deleteImage(image: ImageData) {
        self.deleteImageData(image: image)
    }
    
}
