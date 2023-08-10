/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class LabeledUserSelectField : LabeledRadioGroup{
    
    var users: UserList? = nil
    
    func setupUsers(users: UserList, currentUserId: UUID = .NIL, includingNobody: Bool = false){
        self.users = users
        var values = Array<String>()
        var currentIndex = -1
        for user in users{
            values.append(user.name)
            if user.uuid == currentUserId{
                currentIndex = values.count - 1
            }
        }
        radioGroup.setup(values: values, includingNobody: includingNobody)
        if currentIndex != -1 || includingNobody{
            radioGroup.select(index: currentIndex)
        }
    }
    
    var selectedUser: UserData?{
        if selectedIndex != -1, let users = users{
            return users[selectedIndex]
        }
        return nil
    }
    
}
