/*
 E5IOSUI
 Basic classes and extension for IOS
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class PopupViewController: UIViewController {
    
    var headerView : UIView? = nil
    var titleLabel: UILabel? = nil
    
    var closeButton = UIButton().asIconButton("xmark", color: .label)
    
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let guide = view.safeAreaLayoutGuide
        createHeaderView()
        if let headerView = headerView{
            view.addSubviewWithAnchors(headerView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor)
        }
    }
    
    func createHeaderView(){
        let headerView = UIView()
        setupHeaderView(headerView: headerView)
        self.headerView = headerView
    }
    
    func setupHeaderView(headerView: UIView){
        if let title = title{
            let label = UILabel(header: title)
            headerView.addSubviewWithAnchors(label, top: headerView.topAnchor, insets: defaultInsets)
                .centerX(headerView.centerXAnchor)
            titleLabel = label
        }
        headerView.addSubviewWithAnchors(closeButton, top: titleLabel?.bottomAnchor ?? headerView.topAnchor, trailing: headerView.trailingAnchor, bottom: headerView.bottomAnchor, insets: defaultInsets)
        closeButton.addAction(UIAction(){ action in
            self.dismiss(animated: true)
        }, for: .touchDown)
    }
    
}
