/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ModalViewController: BaseViewController {
    
    var menuView = UIView()
    var contentView = UIView()
    
    var contentInset : NSLayoutConstraint? = nil
    
    override func loadView() {
        super.loadView()
        setupView()
    }
    
    func setupView(){
        contentView.backgroundColor = .systemBackground
        let guide = view.safeAreaLayoutGuide
        view.addSubviewWithAnchors(menuView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, insets: .zero)
        setupMenu()
        view.addSubviewWithAnchors(contentView, top: menuView.bottomAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        setupContentView()
    }
    
    func setupMenu(){
        menuView.backgroundColor = UIColor.systemBackground
        if let title = title{
            let titleLabel = UILabel(header: title)
            menuView.addSubviewWithAnchors(titleLabel, top: menuView.topAnchor, bottom: menuView.bottomAnchor).centerX(menuView.centerXAnchor)
        }
        let closeButton = IconButton(icon: "xmark.circle")
        menuView.addSubview(closeButton)
        closeButton.addAction(UIAction(){ action in
            self.dismiss(animated: true)
        }, for: .touchDown)
        closeButton.setAnchors(top: menuView.topAnchor, trailing: menuView.trailingAnchor, bottom: menuView.bottomAnchor, insets: defaultInsets)
    }
    
    func setupContentView(){
    }
    
}
