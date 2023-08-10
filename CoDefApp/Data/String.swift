/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

extension String {
    
    func localize() -> String{
        return NSLocalizedString(self,comment: "")
    }
    
    func localizeWithColon() -> String{
        return localize() + ": "
    }
    
    func localize(i: Int) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(i))
    }
    
    func localize(s: String) -> String{
        return String(format: NSLocalizedString(self,comment: ""), s)
    }
    
    func localize(b: Bool) -> String{
        return String(format: NSLocalizedString(self,comment: ""), String(b))
    }
    
    func localize(param: String) -> String{
        return String(format: self.localize(), param)
    }
    
    func localize(param1: String, param2: String) -> String{
        return String(format: self.localize(), param1, param2)
    }
    
    func localize(param1: String, param2: String, param3: String) -> String{
        return String(format: self.localize(), param1, param2, param3)
    }
    
    func localizeAsMandatory() -> String{
        return String(format: NSLocalizedString(self,comment: "")) + " *"
    }
    
    func localizeWithColonAsMandatory() -> String{
        return localize() + ":* "
    }
    
    func trim() -> String{
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func removeTimeStringMilliseconds() -> String{
        if self.hasSuffix("Z"), let idx = self.lastIndex(of: "."){
            return self[self.startIndex ..< idx] + "Z"
        }
        return self
    }
    
    func ISO8601Date() -> Date?{
        ISO8601DateFormatter().date(from: self.removeTimeStringMilliseconds())
    }

}
