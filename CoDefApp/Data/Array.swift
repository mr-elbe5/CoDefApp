/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

extension Array{
    
    mutating func remove<T : Equatable>(obj : T){
        for i in 0..<count{
            if obj == self[i] as? T{
                remove(at: i)
                return
            }
        }
    }
    
    func getTypedArray<T>(type: T.Type) -> Array<T>{
        var arr = Array<T>()
        for data in self{
            if let obj = data as? T {
                arr.append(obj)
            }
        }
        return arr
    }
    
}

