/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

extension UIViewController{
    
    var isDarkMode: Bool {
        return self.traitCollection.userInterfaceStyle == .dark
    }
    
    func showAlert(title: String = "alert".localize(), text: String, onOk: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(),style: .default) { action in
            onOk?()
        })
        self.present(alertController, animated: true)
    }
    
    func showDestructiveApprove(title: String = "pleaseApprove".localize(), text: String, onApprove: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localize(), style: .destructive) { action in
            onApprove?()
        })
        alertController.addAction(UIAlertAction(title: "no".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func showApprove(title: String = "pleaseApprove".localize(), text: String, onApprove: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "yes".localize(), style: .default) { action in
            onApprove?()
        })
        alertController.addAction(UIAlertAction(title: "no".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func showAccept(title: String, text: String, onAccept: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(), style: .default) { action in
            onAccept?()
        })
        alertController.addAction(UIAlertAction(title: "cancel".localize(), style: .cancel))
        self.present(alertController, animated: true)
    }
    
    func showDone(title: String, text: String, onOk: (() -> Void)? = nil){
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok".localize(), style: .default){ action in
            onOk?()
        })
        self.present(alertController, animated: true)
    }
    
    func showError(_ reason: String){
        showAlert(title: "error".localize(), text: reason.localize())
    }
    
}

