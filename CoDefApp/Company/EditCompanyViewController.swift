/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import E5IOSUI

class EditCompanyViewController: EditViewController {
    
    var company: CompanyData
    
    var delegate: CompanyDelegate? = nil
    
    var nameField = LabeledTextInput().withTextColor(.black)
    var streetField = LabeledTextInput().withTextColor(.black)
    var zipCodeField = LabeledTextInput().withTextColor(.black)
    var cityField = LabeledTextInput().withTextColor(.black)
    var emailField = LabeledTextInput().withTextColor(.black)
    var phoneField = LabeledTextInput().withTextColor(.black)
    var notesField = LabeledTextareaInput().withTextColor(.black)
    
    override var infoViewController: InfoViewController?{
        EditUserInfoViewController()
    }
    
    init(company: CompanyData){
        self.company = company
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "company".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: company.name)
        contentView.addSubviewAtTop(nameField)
        
        streetField.setupView(labelText: "street".localizeWithColon(), text: company.street)
        contentView.addSubviewAtTop(streetField, topView: nameField)
        
        zipCodeField.setupView(labelText: "zipCode".localizeWithColon(), text: company.zipCode)
        contentView.addSubviewAtTop(zipCodeField, topView: streetField)
        
        cityField.setupView(labelText: "city".localizeWithColon(), text: company.city)
        contentView.addSubviewAtTop(cityField, topView: zipCodeField)
        
        emailField.setupView(labelText: "email".localizeWithColon(), text: company.email)
        contentView.addSubviewAtTop(emailField, topView: cityField)
        
        phoneField.setupView(labelText: "phone".localizeWithColon(), text: company.phone)
        contentView.addSubviewAtTop(phoneField, topView: emailField)
        
        notesField.setupView(labelText: "notes".localizeWithColon(), text: company.notes)
        contentView.addSubviewAtTop(notesField, topView: phoneField)
            .bottom(contentView.bottomAnchor)
        
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            company.name = nameField.text
            company.street = streetField.text
            company.zipCode = zipCodeField.text
            company.city = cityField.text
            company.email = emailField.text
            company.phone = phoneField.text
            company.notes = notesField.text
            company.changed()
            if !AppData.shared.companies.contains(company){
                AppData.shared.companies.append(company)
                AppData.shared.companies.sortByName()
            }
            company.saveData()
            delegate?.companyChanged()
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
        block.addArrangedSubview(InfoHeader("companyEditInfoHeader".localize()))
        block.addSpacer()
        block.addArrangedSubview(UILabel(text: "companyEditInfoText".localize()))
    }
    
}
