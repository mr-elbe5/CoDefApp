/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class UserViewController: ScrollViewController {
    
    var user : UserData
    
    var delegate: UserDelegate? = nil
    
    init(user: UserData){
        self.user = user
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "user".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
            let controller = EditUserViewController(user: self.user)
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash"), primaryAction: UIAction(){ action in
            self.showDestructiveApprove(text: "deleteInfo".localize()){
                if AppData.shared.removeUser(self.user){
                    AppData.shared.save()
                    self.delegate?.userChanged()
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.showError("deleteUserError")
                }
            }
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        items = Array<UIBarButtonItem>()
        items.append(UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = UserInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        }))
        groups.append(UIBarButtonItemGroup.fixedGroup(items: items))
        navigationItem.trailingItemGroups = groups
    }
    
    override func setupContentView(){
        
        let dataSection = ArrangedSectionView()
        contentView.addSubviewFilling(dataSection, insets: defaultInsets)
        
        let nameLine = LabeledText()
        nameLine.setupView(labelText: "name".localizeWithColon(), text: user.name)
        dataSection.addArrangedSubview(nameLine)
        
        let streetLine = LabeledText()
        streetLine.setupView(labelText: "street".localizeWithColon(), text: user.street)
        dataSection.addArrangedSubview(streetLine)
        
        let zipLine = LabeledText()
        zipLine.setupView(labelText: "zipCode".localizeWithColon(), text: user.zipCode)
        dataSection.addArrangedSubview(zipLine)
        
        let cityLine = LabeledText()
        cityLine.setupView(labelText: "city".localizeWithColon(), text: user.city)
        dataSection.addArrangedSubview(cityLine)
        
        let emailLine = LabeledText()
        emailLine.setupView(labelText: "email".localizeWithColon(), text: user.email)
        dataSection.addArrangedSubview(emailLine)
        
        let phoneLine = LabeledText()
        phoneLine.setupView(labelText: "phone".localizeWithColon(), text: user.phone)
        dataSection.addArrangedSubview(phoneLine)
        
        let notesLine = LabeledText()
        notesLine.setupView(labelText: "notes".localizeWithColon(), text: user.notes)
        dataSection.addArrangedSubview(notesLine)
                
    }
    
}

extension UserViewController: UserDelegate{
    
    func userChanged() {
        updateContentView()
        delegate?.userChanged()
    }
    
}

class UserInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("menuSymbolHeader".localize()))
        block.addArrangedSubview(IconInfoText(icon: "pencil", text: "userEditSymbolText".localize(), iconColor: .systemBlue))
        block.addArrangedSubview(IconInfoText(icon: "trash", text: "userDeleteSymbolText".localize(), iconColor: .systemRed))
        block.addArrangedSubview(IconInfoText(icon: "info", text: "infoSymbolText".localize(), iconColor: .systemBlue))
    }
    
}
