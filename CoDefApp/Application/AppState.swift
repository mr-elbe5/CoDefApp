/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation

protocol AppStateDelegate{
    func uploadStateChanged()
    func downloadStateChanged()
}

class AppState : Codable{
    
    static var storeKey = "appState"
    
    static var shared = AppState()
    
    static func load(){
        if let data : AppState = FileController.readJsonFile(storeKey: AppState.storeKey){
            shared = data
        }
        else{
            shared = AppState()
        }
        shared.save()
    }
    
    func save(){
        FileController.saveJsonFile(data: self, storeKey: AppState.storeKey)
    }
    
    enum CodingKeys: String, CodingKey {
        case lastId
        case currentUser
        case standalone
        case useDateTime
        case useNotified
        case serverURL
        case filterCompanyIds
    }
    
    var lastId = Statics.minNewId
    var currentUser = UserData.anonymousUser
    var standalone = true
    var useDateTime = true
    var useNotified = true
    var serverURL = ""
    var filterCompanyIds : Array<Int>
    
    // sync
    
    var uploadedCompanies : Int = 0
    var uploadedProjects : Int = 0
    var uploadedUnits : Int = 0
    var uploadedDefects : Int = 0
    var uploadedStatusChanges : Int = 0
    var uploadedImages : Int = 0
    var uploadedItems: Double = 0.0
    var uploadErrors : Int = 0
    
    var downloadedCompanies : Int = 0
    var downloadedProjects : Int = 0
    var downloadedUnits : Int = 0
    var downloadedDefects : Int = 0
    var downloadedStatusChanges : Int = 0
    var downloadedImages : Int = 0
    var downloadErrors : Int = 0
    
    var newItemsCount: Int = 0
    
    var delegate: AppStateDelegate? = nil
    
    var nextId: Int{
        lastId += 1
        save()
        return lastId
    }
    
    func isLoggedIn() -> Bool{
        return currentUser.isLoggedIn
    }
    
    init(){
        self.filterCompanyIds = Array<Int>()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lastId = try values.decodeIfPresent(Int.self, forKey: .lastId) ?? Statics.minNewId
        if lastId < Statics.minNewId{
            lastId = Statics.minNewId
        }
        currentUser = try values.decodeIfPresent(UserData.self, forKey: .currentUser) ?? UserData.anonymousUser
        standalone = try values.decodeIfPresent(Bool.self, forKey: .standalone) ?? true
        useDateTime = try values.decodeIfPresent(Bool.self, forKey: .useDateTime) ?? true
        useNotified = try values.decodeIfPresent(Bool.self, forKey: .useNotified) ?? true
        serverURL = try values.decodeIfPresent(String.self, forKey: .serverURL) ?? ""
        filterCompanyIds = try values.decodeIfPresent(Array<Int>.self, forKey: .filterCompanyIds) ?? Array<Int>()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastId, forKey: .lastId)
        try container.encode(currentUser, forKey: .currentUser)
        try container.encode(standalone, forKey: .standalone)
        try container.encode(useDateTime, forKey: .useDateTime)
        try container.encode(useNotified, forKey: .useNotified)
        try container.encode(serverURL, forKey: .serverURL)
        try container.encode(filterCompanyIds, forKey: .filterCompanyIds)
    }
    
    func initFilter(){
        if filterCompanyIds.isEmpty{
            for company in AppData.shared.companies{
                filterCompanyIds.append(company.id)
            }
            save()
        }
    }
    
    func isInFilter(id: Int) -> Bool{
        return filterCompanyIds.contains(id)
    }
    
    func addToFilter(id: Int){
        if !filterCompanyIds.contains(id){
            filterCompanyIds.append(id)
            save()
        }
    }
    
    func removeFromFilter(id: Int){
        if filterCompanyIds.contains(id){
            filterCompanyIds.remove(obj: id)
            save()
        }
    }
    
    func updateFilterCompanyIds(allCompanyIds: Array<Int>){
        for id in filterCompanyIds{
            if !allCompanyIds.contains(id){
                filterCompanyIds.remove(obj: id)
            }
        }
        if filterCompanyIds.isEmpty{
            filterCompanyIds.append(contentsOf: allCompanyIds)
        }
        save()
    }
    
    func updateFilterCompanyId(from: Int, to: Int){
        for companyId in filterCompanyIds {
            if companyId == from{
                filterCompanyIds.remove(obj: companyId)
                filterCompanyIds.append(to)
            }
        }
    }
    
    // sync
    
    func companyUploaded() async{
        newItemsCount -= 1
        uploadedCompanies += 1
        uploadedItems += 1.0
        await uploadStateChanged()
    }
    
    func imageUploaded() async{
        newItemsCount -= 1
        uploadedImages += 1
        uploadedItems += 1.0
        await uploadStateChanged()
    }
    
    func projectUploaded() async{
        newItemsCount -= 1
        uploadedProjects += 1
        uploadedItems += 1.0
        await uploadStateChanged()
    }
    
    func unitUploaded() async{
        newItemsCount -= 1
        uploadedUnits += 1
        uploadedItems += 1.0
        await uploadStateChanged()
    }
    
    func defectUploaded() async{
        newItemsCount -= 1
        uploadedDefects += 1
        uploadedItems += 1.0
        await uploadStateChanged()
    }
    
    func statusChangeUploaded() async{
        newItemsCount -= 1
        uploadedStatusChanges += 1
        uploadedItems += 1.0
        await uploadStateChanged()
    }
    
    func uploadError() async{
        uploadErrors += 1
        await uploadStateChanged()
    }
    
    func imageDownloaded() async{
        downloadedImages += 1
        await downloadStateChanged()
    }
    
    func companyDownloaded() async{
        downloadedCompanies += 1
        await downloadStateChanged()
    }
    
    func projectDownloaded() async{
        downloadedProjects += 1
        await downloadStateChanged()
    }
    
    func unitDownloaded() async{
        downloadedUnits += 1
        await downloadStateChanged()
    }
    
    func defectDownloaded() async{
        downloadedDefects += 1
        await downloadStateChanged()
    }
    
    func statusChangeDownloaded() async{
        downloadedStatusChanges += 1
        await downloadStateChanged()
    }
    
    func downloadError() async {
        downloadErrors += 1
        await downloadStateChanged()
    }
    
    
    func hasErrors() -> Bool{
        uploadErrors > 0 || downloadErrors > 0
    }
    
    func uploadStateChanged() async{
        await MainActor.run{
            self.delegate?.uploadStateChanged()
        }
    }
    
    func downloadStateChanged() async {
        await MainActor.run{
            self.delegate?.downloadStateChanged()
        }
    }
    
    func resetUpload(){
        setNewItemsCount()
        uploadedProjects = 0
        uploadedUnits = 0
        uploadedDefects = 0
        uploadedStatusChanges = 0
        uploadedImages = 0
        uploadedCompanies = 0
        uploadErrors = 0
        uploadErrors = 0
        uploadedItems = 0.0
    }
    
    func setNewItemsCount(){
        newItemsCount = AppData.shared.countNewElements()
    }
    
    func resetDownload(){
        downloadedCompanies = 0
        downloadedProjects = 0
        downloadedUnits = 0
        downloadedDefects = 0
        downloadedStatusChanges = 0
        downloadedImages = 0
        downloadErrors = 0
    }
    
    func resetSync(){
        resetUpload()
        resetDownload()
    }
    
}
