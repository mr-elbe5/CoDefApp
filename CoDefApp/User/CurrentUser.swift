/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

class CurrentUser{
    
    static var currentUserStoreKey = "currentUser"
    
    static var instance = UserData.anonymousUser
    
    static func load(){
        instance = FileController.readJsonFile(storeKey: CurrentUser.currentUserStoreKey) ?? UserData.anonymousUser
    }
    
    static func save(){
        FileController.saveJSONFile(data: instance, storeKey: CurrentUser.currentUserStoreKey)
    }
    
    static func identifyAs(user: UserData){
        instance = user
        save()
    }
    
    static func hasProjectEditRight() -> Bool{
        instance.hasProjectEditRight
    }
    
    static func hasGlobalEditRight() -> Bool{
        instance.hasGlobalEditRight
    }
    
    static func hasEditRight(for data: BaseData) -> Bool{
        instance.hasGlobalEditRight || data.hasUserEditRights(userId: instance.uuid)
    }
    
    static func hasSystemRight() -> Bool{
        instance.hasSystemRight
    }
 
}


