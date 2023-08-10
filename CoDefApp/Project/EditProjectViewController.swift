/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
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
        nameField.setupView(labelText: "name".localizeWithColonAsMandatory(), text: project.name)
        contentView.addSubviewAtTop(nameField)
        
        descriptionField.setupView(labelText: "description".localizeWithColon(), text: project.description)
        contentView.addSubviewAtTop(descriptionField, topView: nameField)
        
        labeledCheckboxGroup.setupView(labelText: "users".localizeWithColonAsMandatory())
        contentView.addSubviewAtTop(labeledCheckboxGroup,topView: descriptionField, insets: defaultInsets)
            .bottom(contentView.bottomAnchor)
        
        for user in AppData.shared.users{
            let checkbox = Checkbox()
            checkbox.setup(title: user.name, data: user, isOn: project.userIds.contains(user.uuid))
            labeledCheckboxGroup.addCheckbox(cb: checkbox)
        }
            
    }
    
    override func save() -> Bool{
        if !nameField.text.isEmpty{
            project.name = nameField.text
            project.description = descriptionField.text
            for checkbox in labeledCheckboxGroup.checkboxGroup.checkboxViews{
                if let user = checkbox.data as? UserData, !checkbox.isOn, project.userIds.contains(user.uuid), !project.canRemoveUser(userId: user.uuid){
                    self.showError("userDeleteError")
                    return false
                }
            }
            project.userIds.removeAll()
            for checkbox in labeledCheckboxGroup.checkboxGroup.checkboxViews{
                if let user = checkbox.data as? UserData, checkbox.isOn{
                    project.userIds.append(user.uuid)
                }
            }
            if project.isNew{
                AppData.shared.addProject(project)
                project.isNew = false
            }
            project.updateUsers()
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
    
    var user: UserData
    
    init(user: UserData){
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
