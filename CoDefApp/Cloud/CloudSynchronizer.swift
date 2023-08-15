/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class CloudSynchronizer{
    
    static var shared = CloudSynchronizer()
    
    func loadProjects(syncResult: SyncResult) async{
        let requestUrl = AppState.shared.serverURL+"/api/project/getProjects"
        let params = Dictionary<String,String>()
        do{
            if let projectList: AppData = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
                //print(projectList.projects)
                await MainActor.run{
                    syncResult.projectsLoaded = projectList.projects.count
                    for project in projectList.projects{
                        syncResult.scopesLoaded += project.scopes.count
                        for scope in project.scopes{
                            syncResult.issuesLoaded += scope.defects.count
                        }
                    }
                }
                try await self.loadProjectImages(data: projectList, syncResult: syncResult)
                print("saving project list")
                AppData.shared = projectList
            }
        }
        catch {
            await MainActor.run{
                syncResult.downloadErrors += 1
            }
            print("error loading projects")
        }
    }
    
    func loadImage(image : ImageFile) async -> UIImage?{
        //print("start loading image \(image.id)")
        if image.fileExists(){
            let uiImage = image.getImage()
            return uiImage
        }
        //print("file needs downloading")
        let serverUrl = AppState.shared.serverURL+"/api/image/download/" + String(image.id)
        let params = [
            "scale" : "100"
        ]
        do{
            if let img = try await RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params) {
                //print("received image \(image.id) for \(image.getLocalFileName())")
                image.saveImage(uiImage: img)
                return img
            }
        }
        catch{
            print("file load error")
        }
        return nil
    }
    
    func loadProjectImage(image : ImageFile, syncResult: SyncResult) async throws{
        if image.fileExists(){
            await MainActor.run{
                syncResult.imagesPresent += 1
            }
            return
        }
        //print("file needs downloading")
        let serverUrl = AppState.shared.serverURL+"/api/image/download/" + String(image.id)
        let params = [
            "scale" : "100"
        ]
        if let img = try await RequestController.shared.requestAuthorizedImage(url: serverUrl, withParams: params) {
            image.saveImage(uiImage: img)
            await MainActor.run{
                syncResult.imagesLoaded += 1
            }
        }
        else{
            await MainActor.run{
                syncResult.downloadErrors += 1
            }
        }
    }
    
    func loadProjectImages(data: AppData, syncResult: SyncResult) async throws{
        //print("start loading images")
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in data.projects{
                for scope in project.scopes{
                    if let plan = scope.plan {
                        taskGroup.addTask{
                            do{
                                try await self.loadProjectImage(image: plan, syncResult: syncResult)
                            }
                            catch{
                                await MainActor.run{
                                    syncResult.downloadErrors += 1
                                }
                            }
                        }
                    }
                    for issue in scope.defects{
                        for image in issue.images{
                            taskGroup.addTask{
                                do{
                                    try await self.loadProjectImage(image: image, syncResult: syncResult)
                                }
                                catch{
                                    await MainActor.run{
                                        syncResult.downloadErrors += 1
                                    }
                                }
                            }
                        }
                        for feedback in issue.processingStatuses{
                            for image in feedback.images{
                                taskGroup.addTask{
                                    do{
                                        try await self.loadProjectImage(image: image, syncResult: syncResult)
                                    }
                                    catch{
                                        await MainActor.run{
                                            syncResult.downloadErrors += 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func clearProjectImages(){
        DocumentStore.shared.clearFiles()
    }
    
    func countNewElements() -> Int {
        var count = 0
        for project in AppData.shared.projects{
            for scope in project.scopes{
                for issue in scope.defects{
                    if !issue.synchronized{
                        count += 1
                    }
                    for feedback in issue.processingStatuses{
                        if !feedback.synchronized{
                            count += 1
                        }
                    }
                }
            }
        }
        return count
    }
    
    func uploadNewItems(syncResult: SyncResult) async{
        await withTaskGroup(of: Void.self){ taskGroup in
            for project in AppData.shared.projects{
                for scope in project.scopes{
                    for issue in scope.defects{
                        if !issue.synchronized{
                            taskGroup.addTask{
                                do{
                                    try await self.uploadIssue(issue: issue, scopeCloudId: scope.id, syncResult: syncResult)
                                    await MainActor.run{
                                        syncResult.newElementsCount -= 1
                                    }
                                }
                                catch{
                                    await MainActor.run{
                                        syncResult.uploadErrors += 1
                                    }
                                }
                            }
                        }
                        else{
                            for feedback in issue.processingStatuses{
                                if !feedback.synchronized{
                                    taskGroup.addTask{
                                        do{
                                            try await self.uploadFeedback(feedback: feedback, issueCloudId: issue.id, syncResult: syncResult)
                                            await MainActor.run{
                                                syncResult.newElementsCount -= 1
                                            }
                                        }
                                        catch{
                                            await MainActor.run{
                                                syncResult.uploadErrors += 1
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func uploadIssue(issue: DefectData, scopeCloudId: Int, syncResult: SyncResult) async throws{
        let requestUrl = AppState.shared.serverURL+"/api/defect/uploadNewIssue/" + String(scopeCloudId)
        var params = issue.asDictionary()
        params["creationDate"] = String(issue.creationDate.millisecondsSince1970)
        if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
            print("issue \(response.id) uploaded")
            await MainActor.run{
                syncResult.feedbacksUploaded += 1
            }
            issue.id = response.id
            issue.displayId = response.id
            await withTaskGroup(of: Void.self){ taskGroup in
                var count = 0
                for image in issue.images{
                    count += 1
                    do{
                        if try await uploadIssueImage(image: image, issueCloudId: response.id, count: count){
                            await MainActor.run{
                                syncResult.imagesUploaded += 1
                            }
                        }
                        else{
                            await MainActor.run{
                                syncResult.uploadErrors += 1
                            }
                        }
                    }
                    catch{
                        await MainActor.run{
                            syncResult.uploadErrors += 1
                        }
                    }
                }
                for feeedback in issue.processingStatuses{
                    if !feeedback.synchronized{
                        do{
                            try await uploadFeedback(feedback: feeedback, issueCloudId: response.id, syncResult: syncResult)
                        }
                        catch{
                            await MainActor.run{
                                syncResult.uploadErrors += 1
                            }
                        }
                    }
                }
            }
        }
        else{
            await MainActor.run{
                syncResult.uploadErrors += 1
            }
        }
    }
    
    func uploadFeedback(feedback: DefectStatusData, issueCloudId: Int, syncResult: SyncResult) async throws{
        let requestUrl = AppState.shared.serverURL+"/api/defect/uploadNewFeedback/" + String(issueCloudId)
        var params = feedback.getUploadParams()
        params["creationDate"] = String(feedback.creationDate.millisecondsSince1970)
        params["issueId"] = String(issueCloudId)
        params["dueDate"] = String(feedback.dueDate.millisecondsSince1970)
        if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: params) {
            print("feedback \(response.id) uploaded")
            await MainActor.run{
                syncResult.feedbacksUploaded += 1
            }
            feedback.id = response.id
            await withTaskGroup(of: Void.self){ taskGroup in
                var count = 0
                for image in feedback.images{
                    count += 1
                    do{
                        if try await uploadFeedbackImage(image: image, feedbackCloudId: response.id, count: count){
                            await MainActor.run{
                                syncResult.imagesUploaded += 1
                            }
                        }
                        else{
                            await MainActor.run{
                                syncResult.uploadErrors += 1
                            }
                        }
                    }
                    catch{
                        await MainActor.run{
                            syncResult.uploadErrors += 1
                        }
                    }
                    
                }
            }
            
        }
        else{
            await MainActor.run{
                syncResult.uploadErrors += 1
            }
        }
    }
    
    func synchronize(syncResult: SyncResult){
        Task{
            await uploadNewItems(syncResult: syncResult)
            await MainActor.run{
                syncResult.progress = 50.0
            }
            await loadProjects(syncResult: syncResult)
            await MainActor.run{
                syncResult.progress = 100.0
            }
        }
    }
    
    func uploadIssueImage(image: ImageFile, issueCloudId: Int, count: Int) async throws -> Bool{
        let requestUrl = AppState.shared.serverURL+"/api/defect/uploadNewIssueImage/" + String(issueCloudId)
        let newFileName = "img-\(issueCloudId)-\(count).jpg"
        //print("get image \(newFileName)")
        let uiImage = image.getImage()
        if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: newFileName) {
            //print("issue image uploaded with id \(response.id)")
            image.id = response.id
            return true
        }
        return false
    }
    
    func uploadFeedbackImage(image: ImageFile, feedbackCloudId: Int, count: Int) async throws -> Bool{
        let requestUrl = AppState.shared.serverURL+"/api/defect/uploadNewFeedbackImage/" + String(feedbackCloudId)
        let newFileName = "img-\(feedbackCloudId)-\(count).jpg"
        let uiImage = image.getImage()
        if let response = try await RequestController.shared.uploadAuthorizedImage(url: requestUrl, withImage: uiImage, fileName: newFileName) {
            //print("feedback image uploaded with id \(response.id)")
            image.id = response.id
            return true
        }
        return false
    }
    
}
