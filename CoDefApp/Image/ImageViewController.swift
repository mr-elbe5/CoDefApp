/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ImageViewController: BaseViewController {
    
    var scrollView : ImageScrollView
    var fitImage: Bool
    
    var deleteDelegate: ImageFileDeleteDelegate? = nil
    
    var imageView: UIImageView{
        scrollView.imageView
    }
    
    var imageFile: ImageData
    
    var currentScale: CGFloat{
        scrollView.image.size.width/scrollView.contentSize.width
    }
    
    init(imageFile: ImageData, fitImage: Bool = true){
        self.imageFile = imageFile
        self.fitImage = fitImage
        scrollView = ImageScrollView(image: imageFile.getImage())
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
        
        setupNavigationBar()
    }
    
    func setupNavigationBar(){
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "share".localize(), image: UIImage(systemName: "square.and.arrow.up"), primaryAction: UIAction(){ action in
            self.shareImage(image: self.imageFile)
        }))
        
        if deleteDelegate != nil{
            items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash"), primaryAction: UIAction(){ action in
                self.showDestructiveApprove(title: "confirmDeleteImage".localize(), text: "deleteInfo".localize()){
                    self.deleteDelegate?.deleteImage(image: self.imageFile)
                    self.navigationController?.popViewController(animated: true)
                }
            }))
        }
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = ImageInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    func setupViews(){
        let guide = view.safeAreaLayoutGuide
        scrollView.backgroundColor = .systemBackground
        view .addSubviewWithAnchors(scrollView, top: guide.topAnchor, leading: guide.leadingAnchor, trailing: guide.trailingAnchor, bottom: guide.bottomAnchor, insets: .zero)
        setupScrollView()
    }
    
    func setupScrollView(){
        scrollView.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if fitImage{
            scrollView.minimumZoomScale = scrollView.bounds.width / imageFile.getImage().size.width
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
    }
    
}
