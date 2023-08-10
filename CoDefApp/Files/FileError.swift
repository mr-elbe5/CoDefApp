/*
 Defect and Issue Tracker
 App for tracking plan based defects and issues 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

enum FileError: Swift.Error {
    case read
    case save
    case unauthorized
    case unexpected
}

extension FileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .read: return "readError".localize()
        case .save: return "saveError".localize()
        case .unauthorized: return "unauthorizedError".localize()
        case .unexpected: return "unexpectedError".localize()
        }
    }
}

