/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit
import StoreKit

protocol SettingsDelegate{
    func loginChanged()
}

class SettingsViewController: ScrollViewController {
    
    var loginSection = SectionView()
    
    var serverUrlField = LabeledTextInput()
    var loginNameField = LabeledTextInput()
    var passwordField = LabeledTextInput()
    
    var loginButton = TextButton(text: "login".localize(), withBorder: true)
    var logoutButton = TextButton(text: "logout".localize(), tintColor: .systemRed, withBorder: true)
    
    var cleanupSection = SectionView()
    
    var delegate: SettingsDelegate? = nil
    
    override func loadView() {
        title = "settings".localize()
        super.loadView()
        modalPresentationStyle = .fullScreen
        
        let item = UIBarButtonItem(title: "info", image: UIImage(systemName: "info"), primaryAction: UIAction(){ action in
            let controller = SettingsInfoViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        navigationItem.rightBarButtonItem = item
        
    }
    
    override func setupContentView() {
        contentView.addSubviewAtTop(loginSection)
        setupLoginSection()
        logoutButton.isEnabled = AppState.shared.currentUser.isLoggedIn
        contentView.addSubviewAtTop(cleanupSection, topView: loginSection)
            .bottom(contentView.bottomAnchor, inset: -defaultInset)
        setupCleanupSection()
    }
    
    func setupLoginSection(){
        
        let label  = UILabel(header: "cloud".localize())
        loginSection.addSubviewAtTopCentered(label)
        
        serverUrlField.setupView(labelText: "serverURL".localize(), text: AppState.shared.serverURL)
        loginSection.addSubviewAtTop(serverUrlField, topView: label)
        
        loginNameField.setupView(labelText: "loginName".localize(), text: AppState.shared.currentUser.login)
        loginSection.addSubviewAtTop(loginNameField, topView: serverUrlField)
        
        passwordField.setupView(labelText: "password".localize(), text: "")
        loginSection.addSubviewAtTop(passwordField, topView: loginNameField)
        
        loginButton.addAction(UIAction(){ action in
            Task{
                if try await self.doLogin(serverURL: self.serverUrlField.text, login: self.loginNameField.text, password: self.passwordField.text){
                    self.showDone(title: "ok".localize(), text: "loggedIn".localize())
                    self.delegate?.loginChanged()
                }
            }
        }, for: .touchDown)
        loginSection.addSubviewWithAnchors(loginButton, top: passwordField.bottomAnchor, trailing: loginSection.centerXAnchor, insets: doubleInsets)
            .bottom(loginSection.bottomAnchor, inset: -defaultInset)
        
        logoutButton.setTitleColor(.systemGray, for: .disabled)
        logoutButton.addAction(UIAction(){ action in
            AppState.shared.currentUser.token = ""
            DispatchQueue.main.async{
                AppState.shared.save()
                self.delegate?.loginChanged()
            }
        }, for: .touchDown)
        loginSection.addSubviewWithAnchors(logoutButton, top: passwordField.bottomAnchor, leading: loginSection.centerXAnchor, insets: doubleInsets)
            .bottom(loginSection.bottomAnchor, inset: -defaultInset)
        
    }
    
    func setupCleanupSection(){
        let label  = UILabel(header: "images".localize())
        cleanupSection.addSubviewAtTopCentered(label)
        
        let cleanupButton = TextButton(text: "cleanup".localize(), withBorder: true)
        cleanupButton.addAction(UIAction(){ action in
            self.cleanup()
        }, for: .touchDown)
        cleanupSection.addSubviewAtTopCentered(cleanupButton, topView: label)
            .bottom(cleanupSection.bottomAnchor, inset: -defaultInset)
    }
    
    func doLogin(serverURL: String, login: String, password: String) async throws -> Bool{
        var url = serverURL
        if url.hasSuffix("/"){
            url=String(url.dropLast(1))
        }
        let requestUrl = url+"/api/user/login"
        let params = [
            "login" : login,
            "password" : password,
        ]
        if let currentUser: UserData = try await RequestController.shared.requestJson(url: requestUrl, withParams: params) {
            if (currentUser.isLoggedIn){
                AppState.shared.serverURL = url
                AppState.shared.currentUser = currentUser
                AppState.shared.save()
                //print("\(currentuser.dump())")
                self.logoutButton.isEnabled = AppState.shared.currentUser.isLoggedIn
                return true
            }
            return false
        }
        return false
    }
    
    func cleanup(){
        let usedImageNames = AppData.shared.usedImageNames
        let count = FileController.cleanupFiles(usedNames: usedImageNames)
        showDone(title: "success".localize(), text: "filesDeleted".localizeWithColon() + " " + String(count))
    }
    
}

class SettingsInfoViewController: InfoViewController {
    
    override func setupInfos(){
        let block = InfoBlock()
        /*stackView.addArrangedSubview(block)
        block.stackView.addArrangedSubview(InfoHeader("settingsInfoLoginHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("settingsInfoLoginText".localize()))
        stackView.addSpacer()
        block = InfoBlock()*/
        stackView.addArrangedSubview(block)
        block.stackView.addArrangedSubview(InfoHeader("settingsInfoCleanupHeader".localize()))
        block.stackView.addArrangedSubview(InfoText("settingsInfoCleanupText".localize()))
    }
    
}
