/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class ProjectDailyReport : ContentData{
    
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
        super.init()
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
    
    func setWeatherData(from weatherData: WeatherData){
        weatherCoco = weatherData.getWeatherCoco()
        weatherWspd = String(Int(weatherData.weatherWspd))
        weatherWdir = weatherData.getWindDirection()
        weatherTemp = String(Int(weatherData.weatherTemp))
        weatherRhum = String(Int(weatherData.weatherRhum))
    }
    
}

typealias ProjectDailyReportList = ContentDataArray<ProjectDailyReport>

extension ProjectDailyReportList{
    
    func getProjectDailyReport(id: Int) -> ProjectDailyReport?{
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
