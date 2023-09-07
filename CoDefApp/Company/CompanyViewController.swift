/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class CompanyViewController: ScrollViewController {
    
    var company : CompanyData
    
    var delegate: CompanyDelegate? = nil
    
    init(company: CompanyData){
        self.company = company
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "company".localize()
        super.loadView()
        
        var groups = Array<UIBarButtonItemGroup>()
        var items = Array<UIBarButtonItem>()
        if AppState.shared.standalone{
            items.append(UIBarButtonItem(title: "edit".localize(), image: UIImage(systemName: "pencil"), primaryAction: UIAction(){ action in
                let controller = EditCompanyViewController(company: self.company)
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }))
            items.append(UIBarButtonItem(title: "delete".localize(), image: UIImage(systemName: "trash"), primaryAction: UIAction(){ action in
                self.showDestructiveApprove(text: "deleteInfo".localize()){
                    if AppData.shared.removeCompany(self.company){
                        AppData.shared.save()
                        self.delegate?.companyChanged()
                        self.navigationController?.popViewController(animated: true)
                    }
                    else{
                        self.showError("deleteUserError")
                    }
                }
            }))
            groups.append(UIBarButtonItemGroup.fixedGroup(representativeItem: UIBarButtonItem(title: "actions".localize(), image: UIImage(systemName: "filemenu.and.selection")), items: items))
        }
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
        nameLine.setupView(labelText: "name".localizeWithColon(), text: company.name)
        dataSection.addArrangedSubview(nameLine)
        
        let streetLine = LabeledText()
        streetLine.setupView(labelText: "street".localizeWithColon(), text: company.street)
        dataSection.addArrangedSubview(streetLine)
        
        let zipLine = LabeledText()
        zipLine.setupView(labelText: "zipCode".localizeWithColon(), text: company.zipCode)
        dataSection.addArrangedSubview(zipLine)
        
        let cityLine = LabeledText()
        cityLine.setupView(labelText: "city".localizeWithColon(), text: company.city)
        dataSection.addArrangedSubview(cityLine)
        
        let emailLine = LabeledText()
        emailLine.setupView(labelText: "email".localizeWithColon(), text: company.email)
        dataSection.addArrangedSubview(emailLine)
        
        let phoneLine = LabeledText()
        phoneLine.setupView(labelText: "phone".localizeWithColon(), text: company.phone)
        dataSection.addArrangedSubview(phoneLine)
        
        let notesLine = LabeledText()
        notesLine.setupView(labelText: "notes".localizeWithColon(), text: company.notes)
        dataSection.addArrangedSubview(notesLine)
                
    }
    
}

extension CompanyViewController: CompanyDelegate{
    
    func companyChanged() {
        updateContentView()
        delegate?.companyChanged()
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
