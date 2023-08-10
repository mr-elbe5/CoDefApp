/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class InfoViewController: ScrollViewController {
    
    var stackView = UIStackView()
    
    override func loadView() {
        title = "info".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        stackView.axis = .vertical
        contentView.addSubviewFilling(stackView, insets: defaultInsets)
        setupInfos()
    }
    
    func setupInfos(){
        
    }
    
    func addBlock() -> InfoBlock{
        let block = InfoBlock()
        stackView.addArrangedSubview(block)
        return block
    }
    
}

class InfoHeader : UIView{
    
    let label = UILabel()
    
    init(_ text: String, paddingTop: CGFloat = Insets.defaultInset){
        super.init(frame: .zero)
        label.text = text
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        addSubview(label)
        label.setAnchors(leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
            .top(topAnchor, inset: paddingTop)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class InfoText : UIView{
    
    let label = UILabel()
    
    init(_ text: String){
        super.init(frame: .zero)
        label.text = text
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .label
        addSubview(label)
        label.fillView(view: self, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class IconInfoText : UIView{
    
    let iconContainer = UIView()
    let iconView = UIImageView()
    let iconText = UILabel()
    
    init(icon: String, text: String, iconColor : UIColor = .systemBlue){
        super.init(frame: .zero)
        addSubview(iconContainer)
        iconContainer.setAnchors(top: topAnchor, leading: leadingAnchor, insets: defaultInsets)
            .width(30)
        iconView.image = UIImage(systemName: icon)
        iconView.scaleBy(1.25)
        iconView.tintColor = iconColor
        iconText.text = text
        commonInit()
    }
    
    init(image: String, text: String){
        super.init(frame: .zero)
        addSubview(iconContainer)
        iconContainer.setAnchors(top: topAnchor, leading: leadingAnchor, insets: defaultInsets)
            .width(30)
        iconView.image = UIImage(named: image)
        iconText.text = text
        commonInit()
    }
    
    private func commonInit(){
        iconText.numberOfLines = 0
        iconText.textColor = .label
        iconContainer.addSubview(iconView)
        iconView.setAnchors(top: topAnchor, leading: leadingAnchor, insets: defaultInsets)
        addSubview(iconText)
        iconText.setAnchors(top: topAnchor, leading: iconContainer.trailingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: defaultInsets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

typealias InfoBlock = ArrangedSectionView

