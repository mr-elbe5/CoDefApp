/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

typealias UserList = Array<UserData>

extension UserList{
    
    var names: Array<String>{
        var list = Array<String>()
        for i in 0..<count{
            list.append(self[i].name)
        }
        return list
    }
    
    func user(withId uuid: UUID)-> UserData?{
        if uuid == UserData.anonymousUserId{
            return UserData.anonymousUser
        }
        for user in self{
            if user.uuid == uuid{
                return user
            }
        }
        return nil
    }
    
    func user(withCloudId id: Int)-> UserData?{
        for user in self{
            if user.cloudId == id{
                return user
            }
        }
        return nil
    }
    
    func cloudId(ofUserWithId uuid: UUID) -> Int{
        user(withId: uuid)?.cloudId ?? 0
    }
    
    func name(ofUserWithId uuid: UUID) -> String{
        user(withId: uuid)?.name ?? ""
    }
    
}
