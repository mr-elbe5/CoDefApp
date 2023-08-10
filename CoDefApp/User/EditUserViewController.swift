/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class EditUserViewController: EditViewController {
    
    var user: UserData
    
    var delegate: UserDelegate? = nil
    
    var nameField = LabeledTextInput()
    var streetField = LabeledTextInput()
    var zipCodeField = LabeledTextInput()
    var cityField = LabeledTextInput()
    var emailField = LabeledTextInput()
    var phoneField = LabeledTextInput()
    var notesField = LabeledTextareaInput()
    
    override var infoViewController: InfoViewController?{
        EditUserInfoViewController()
    }
    
    init(user: UserData){
        self.user = user
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "user".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: user.name)
        contentView.addSubviewAtTop(nameField)
        
        streetField.setupView(labelText: "street".localizeWithColon(), text: user.street)
        contentView.addSubviewAtTop(streetField, topView: nameField)
        
        zipCodeField.setupView(labelText: "zipCode".localizeWithColon(), text: user.zipCode)
        contentView.addSubviewAtTop(zipCodeField, topView: streetField)
        
        cityField.setupView(labelText: "city".localizeWithColon(), text: user.city)
        contentView.addSubviewAtTop(cityField, topView: zipCodeField)
        
        emailField.setupView(labelText: "email".localizeWithColon(), text: user.email)
        contentView.addSubviewAtTop(emailField, topView: cityField)
        
        phoneField.setupView(labelText: "phone".localizeWithColon(), text: user.phone)
        contentView.addSubviewAtTop(phoneField, topView: emailField)
        
        notesField.setupView(labelText: "notes".localizeWithColon(), text: user.notes)
        contentView.addSubviewAtTop(notesField, topView: phoneField)
            .bottom(contentView.bottomAnchor)
        
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            user.name = nameField.text
            user.street = streetField.text
            user.zipCode = zipCodeField.text
            user.city = cityField.text
            user.email = emailField.text
            user.phone = phoneField.text
            user.notes = notesField.text
            user.changed()
            if user.isNew{
                AppData.shared.addUser(user)
                user.isNew = false
            }
            user.saveData()
            delegate?.userChanged()
            return true
        }
        else{
            showError("mandatoryFieldsError")
        }
        return false
    }
    
}

class EditUserInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = InfoBlock()
        stackView.addArrangedSubview(block)
        block.addArrangedSubview(InfoHeader("userEditInfoHeader".localize()))
        block.addSpacer()
        block.addArrangedSubview(UILabel(text: "userEditInfoText".localize()))
    }
    
}
