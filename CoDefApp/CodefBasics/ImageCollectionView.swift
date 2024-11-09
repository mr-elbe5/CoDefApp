/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

protocol ImageCollectionDelegate: ImageFileViewDelegate, ImageFileDeleteDelegate{
    
}

class ImageCollectionView : UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    static var imageSize = CGSize(width: 300, height: 300)
    
    var images: Array<ImageData>
    
    var imageDelegate: ImageCollectionDelegate? = nil
    
    var layout = UICollectionViewFlowLayout()
    
    var enableDelete : Bool
    
    var heightConstraint : NSLayoutConstraint? = nil
    
    func updateHeightConstraint(){
        heightConstraint?.constant = defaultHeight
        setNeedsUpdateConstraints()
    }
    
    var defaultHeight: CGFloat{
        let width = mainController.view.frame.width
        if images.isEmpty{
            return 0
        }
        var height = 2*defaultInset
        var lineWidth : CGFloat = width
        for _ in 0..<images.count{
            if lineWidth + layout.minimumInteritemSpacing + ImageCollectionView.imageSize.width > width{
                height += ImageCollectionView.imageSize.height + layout.minimumLineSpacing
                lineWidth = 0
            }
            else{
                lineWidth += layout.minimumInteritemSpacing + ImageCollectionView.imageSize.width
            }
        }
        return height
    }
    
    init(images: Array<ImageData>, enableDelete: Bool){
        self.images = images
        self.enableDelete = enableDelete
        super.init(frame: .zero, collectionViewLayout: layout)
        backgroundColor = .clear
        setGrayRoundedBorders()
        setAnchors()
        heightConstraint = heightAnchor.constraint(equalToConstant: defaultHeight)
        heightConstraint?.isActive = true
        delegate = self
        register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.reuseIdentifier)
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func selectedCellImage() -> ImageData?{
        for cell in self.visibleCells{
            if cell.isSelected, let cell = cell as? ImageCollectionCell, let image = cell.image{
                return image
            }
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = images[indexPath.row]
        let cell = dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath)
        let imageView = ImageFileView(imageFile: image)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTap)))
        cell.contentView.removeAllSubviews()
        cell.contentView.addSubviewFilling(imageView)
        return cell
    }
    
    func collectionView(_: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt: IndexPath) -> CGSize{
        ImageCollectionView.imageSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        defaultInsets
    }
    
    @objc func imageTap(sender: Any?){
        if let sender = sender as? UITapGestureRecognizer, let imageView = sender.view as? ImageFileView {
            imageDelegate?.viewImage(image: imageView.imageFile, imageDeleteDelegate: enableDelete ? imageDelegate : nil)
        }
    }
    
}

class ImageCollectionCell: UICollectionViewCell{
    
    static var reuseIdentifier = "imageCell"
    
    var image: ImageData? = nil
    
    func setup(image: ImageData){
        self.image = image
        contentView.removeAllSubviews()
        let backgroundView = UIView()
        backgroundView.backgroundColor = .red
        
        let imageView = UIImageView(image: image.getImage())
        
        contentView.addSubviewFilling(imageView, insets: smallInsets)
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .red
        selectedBackgroundView?.setAnchors(top: topAnchor, leading: leadingAnchor,trailing: trailingAnchor,bottom: bottomAnchor)
    }
    
}

    
