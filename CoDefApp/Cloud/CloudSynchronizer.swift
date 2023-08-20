/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class CloudSynchronizer{
    
    static var shared = CloudSynchronizer()
    
    func upload(syncResult: SyncResult){
        Task{
            await AppData.shared.uploadNewItems(syncResult: syncResult)
        }
    }
    
    func download(syncResult: SyncResult){
        Task{
            await AppData.shared.loadProjects(syncResult: syncResult)
            await MainActor.run{
                syncResult.downloadProgress = 1.0
            }
        }
    }
    
}
