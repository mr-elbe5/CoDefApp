/*
 Construction Defect Tracker
 App for tracking construction defects  
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

enum AuthorizationError: Swift.Error {
    case rejected
    case unexpected
}

extension AuthorizationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .rejected: return "rejectedError".localize()
        case .unexpected: return "unexpectedError".localize()
        }
    }
}
