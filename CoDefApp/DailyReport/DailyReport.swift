/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class DailyReport : ContentData{
    
    enum CodingKeys: String, CodingKey {
        case idx
        case weatherCoco
        case weatherWspd
        case weatherWdir
        case weatherTemp
        case weatherRhum
        case companyBriefings
        case images
    }
    
    var idx: Int = 1
    var weatherCoco: String = ""
    var weatherWspd: String = ""
    var weatherWdir: String = ""
    var weatherTemp: String = ""
    var weatherRhum: String = ""
    var companyBriefings = Array<CompanyBriefing>()
    var images = ImageList()
    
    var project: ProjectData!
    
    var projectCompanies: CompanyList{
        project.companies
    }
    
    init(project: ProjectData){
        self.project = project
        idx = project.nextReportIdx
        super.init()
        setDisplayName()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        idx = try values.decode(Int.self, forKey: .idx)
        weatherCoco = try values.decodeIfPresent(String.self, forKey: .weatherCoco) ?? ""
        weatherWspd = try values.decodeIfPresent(String.self, forKey: .weatherWspd) ?? ""
        weatherWdir = try values.decodeIfPresent(String.self, forKey: .weatherWdir) ?? ""
        weatherTemp = try values.decodeIfPresent(String.self, forKey: .weatherTemp) ?? ""
        weatherRhum = try values.decodeIfPresent(String.self, forKey: .weatherRhum) ?? ""
        companyBriefings = try values.decodeIfPresent(Array<CompanyBriefing>.self, forKey: .companyBriefings) ?? Array<CompanyBriefing>()
        images = try values.decodeIfPresent(ImageList.self, forKey: .images) ?? ImageList()
        if displayName.isEmpty{
            setDisplayName()
        }
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idx, forKey: .idx)
        try container.encode(weatherCoco, forKey: .weatherCoco)
        try container.encode(weatherWspd, forKey: .weatherWspd)
        try container.encode(weatherWdir, forKey: .weatherWdir)
        try container.encode(weatherTemp, forKey: .weatherTemp)
        try container.encode(weatherRhum, forKey: .weatherRhum)
        try container.encode(companyBriefings, forKey: .companyBriefings)
        try container.encode(images, forKey: .images)
    }
    
    func setDisplayName(){
        displayName = "\(idx) (\(creationDate.dateString()))"
    }
    
    func projectCompany(id: Int) -> CompanyData?{
        projectCompanies.first(where: {
            $0.id == id
        })
    }
    
    func setWeatherData(from weatherData: WeatherData){
        weatherCoco = weatherData.getWeatherCoco()
        weatherWspd = String(Int(weatherData.weatherWspd))
        weatherWdir = weatherData.getWindDirection()
        weatherTemp = String(Int(weatherData.weatherTemp))
        weatherRhum = String(Int(weatherData.weatherRhum))
    }
    
    override var uploadParams: Dictionary<String,String>{
        var dict = super.uploadParams
        dict["idx"]=String(idx)
        dict["weatherCoco"]=weatherCoco
        dict["weatherWspd"]=weatherWspd
        dict["weatherWdir"]=weatherWdir
        dict["weatherTemp"]=weatherTemp
        dict["weatherRhum"]=weatherRhum
        for briefing in companyBriefings{
            dict["company_\(briefing.companyId)_present"] = "true"
            dict["company_\(briefing.companyId)_activity"] = briefing.activity
            dict["company_\(briefing.companyId)_briefing"] = briefing.briefing
        }
        return dict
    }
    
    func synchronizeFrom(_ fromData: DailyReport) async{
        await super.synchronizeFrom(fromData)
        idx = fromData.idx
        weatherCoco = fromData.weatherCoco
        weatherWspd = fromData.weatherWspd
        weatherTemp = fromData.weatherTemp
        weatherRhum = fromData.weatherRhum
        companyBriefings.removeAll()
        for briefing in fromData.companyBriefings{
            companyBriefings.append(briefing)
        }
        for image in fromData.images{
            if let presentImage = images.getImageData(id: image.id){
                await presentImage.synchronizeFrom(image)
            }
            else{
                images.append(image)
                AppState.shared.downloadedImages += 1
            }
        }
    }
    
    func uploadToServer() async{
        if !isOnServer{
            do{
                let requestUrl = "\(AppState.shared.serverURL)/api/dailyreport/uploadReport/\(id)?projectId=\(project.id)"
                if let response: IdResponse = try await RequestController.shared.requestAuthorizedJson(url: requestUrl, withParams: uploadParams) {
                    print("report \(id) uploaded with new id \(response.id)")
                    await AppState.shared.dailyReportUploaded()
                    id = response.id
                    isOnServer = true
                    saveData()
                    await uploadImages()
                }
                else{
                    await AppState.shared.uploadError()
                    throw "report upload error"
                }
            }
            catch let(err){
                print(err)
                await AppState.shared.uploadError()
            }
        }
    }
    
    func uploadImages() async{
        for image in images{
            await image.uploadToServer(contentId: id)
        }
    }
    
    func sendDownloaded() async{
        await AppState.shared.dailyReportDownloaded()
    }
    
}

typealias DailyReportList = ContentDataArray<DailyReport>

extension DailyReportList{
    
    func getProjectDailyReport(id: Int) -> DailyReport?{
        for data in self{
            if data.id == id {
                return data
            }
        }
        return nil
    }
    
}

protocol DailyReportDelegate{
    func dailyReportChanged()
}
