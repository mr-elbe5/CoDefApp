/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class EditProjectViewController: EditViewController{
    
    var project: ProjectData
    
    var delegate: ProjectDelegate? = nil
    
    var nameField = LabeledTextInput()
    var descriptionField = LabeledTextareaInput()
    var labeledCheckboxGroup = LabeledCheckboxGroup()
    
    override var infoViewController: InfoViewController?{
        EditProjectInfoViewController()
    }
    
    init(project: ProjectData){
        self.project = project
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        title = "project".localize()
        super.loadView()
    }
    
    override func setupContentView() {
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: project.displayName)
        contentView.addSubviewAtTop(nameField)
        
        descriptionField.setupView(labelText: "description".localizeWithColon(), text: project.description)
        contentView.addSubviewAtTop(descriptionField, topView: nameField)
        
        labeledCheckboxGroup.setupView(labelText: "companies".localizeWithColonAsMandatory())
        contentView.addSubviewAtTop(labeledCheckboxGroup,topView: descriptionField, insets: defaultInsets)
            .bottom(contentView.bottomAnchor)
        
        for company in AppData.shared.companies{
            let checkbox = Checkbox()
            checkbox.setup(title: company.name, data: company, isOn: project.companyIds.contains(company.id))
            labeledCheckboxGroup.addCheckbox(cb: checkbox)
        }
            
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty && labeledCheckboxGroup.checkboxGroup.hasSelection{
            project.displayName = nameField.text
            project.description = descriptionField.text
            for checkbox in labeledCheckboxGroup.checkboxGroup.checkboxViews{
                if let company = checkbox.data as? CompanyData, !checkbox.isOn, project.companyIds.contains(company.id), !project.canRemoveCompany(companyId: company.id){
                    self.showError("companyDeleteError")
                    return false
                }
            }
            project.companyIds.removeAll()
            for checkbox in labeledCheckboxGroup.checkboxGroup.checkboxViews{
                if let company = checkbox.data as? CompanyData, checkbox.isOn{
                    project.companyIds.append(company.id)
                }
            }
            if !AppData.shared.projects.contains(project){
                AppData.shared.addProject(project)
                AppData.shared.projects.sortByDisplayName()
            }
            project.updateCompanies()
            project.changed()
            project.saveData()
            delegate?.projectChanged()
            return true
        }
        else{
            showError("mandatoryFieldsError")
        }
        return false
    }
    
}

class SelectUserButton: UIButton{
    
    var user: CompanyData
    
    init(user: CompanyData){
        self.user=user
        super.init(frame: .zero)
        self.setTitle(user.name, for: .normal)
        self.setTitleColor(.systemBlue, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class EditProjectInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = addBlock()
        block.addArrangedSubview(InfoHeader("projectEditInfoHeader".localize()))
        block.addArrangedSubview(InfoText( "projectEditInfoText".localize()))
    }
    
}
