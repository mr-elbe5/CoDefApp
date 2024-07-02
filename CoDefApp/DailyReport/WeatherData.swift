/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import E5Data

class WeatherData : Decodable{
    
    static func getWeatherData(weatherStation: String) async throws -> WeatherData? {
        if !AppData.shared.serverSettings.meteoStatKey.isEmpty{
            let dateString = Date.localDate.simpleDateString()
            let url = "https://meteostat.p.rapidapi.com/stations/hourly?station=\(weatherStation)&start=\(dateString)&end=\(dateString)&tz=\(AppData.shared.serverSettings.timeZoneName.toURL().replacing("/", with: "%2F"))&units=metric"
            if let request = RequestController.shared.createRequest(url: url, method: "GET",
                                                                    headerFields: ["X-RapidApi-Key" : AppData.shared.serverSettings.meteoStatKey],
                                                                    params: nil){
                if let weatherDataList: WeatherDataList = try await RequestController.shared.launchJsonRequest(with: request), let weatherData = weatherDataList.getWeatherData(date: Date.now){
                    return weatherData
                }
            }
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case time
        case coco
        case wspd
        case wdir
        case temp
        case rhum
    }
    
    var time: String = ""
    var weatherCoco: Int = 0
    var weatherWspd: Double = 0
    var weatherWdir: Double = 0
    var weatherTemp: Double = 0
    var weatherRhum: Double = 0
    
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        time = try values.decodeIfPresent(String.self, forKey: .time) ?? ""
        weatherCoco = try values.decodeIfPresent(Int.self, forKey: .coco) ?? 0
        weatherWspd = try values.decodeIfPresent(Double.self, forKey: .wspd) ?? 0
        weatherWdir = try values.decodeIfPresent(Double.self, forKey: .wdir) ?? 0
        weatherTemp = try values.decodeIfPresent(Double.self, forKey: .temp) ?? 0
        weatherRhum = try values.decodeIfPresent(Double.self, forKey: .rhum) ?? 0
    }
    
    public func getWeatherCoco() -> String{
        switch weatherCoco {
        case 1 : return "weather.clear".localize()
        case 2 : return  "weather.fair".localize()
        case 3 : return  "weather.cloudy".localize()
        case 4 : return  "weather.overcast".localize()
        case 5 : return  "weather.fog".localize()
        case 6 : return  "weather.freezingFog".localize()
        case 7 : return  "weather.lightRain".localize()
        case 8 : return  "weather.rain".localize()
        case 9 : return  "weather.heavyRain".localize()
        case 10 : return  "weather.freezingRain".localize()
        case 11 : return  "weather.heavyFreezingRain".localize()
        case 12 : return  "weather.sleet".localize()
        case 13 : return  "weather.heavySleet".localize()
        case 14 : return  "weather.lightSnowfall".localize()
        case 15 : return  "weather.snowfall".localize()
        case 16 : return  "weather.heavySnowfall".localize()
        case 17 : return  "weather.rainShower".localize()
        case 18 : return  "weather.heavyRainShower".localize()
        case 19 : return  "weather.sleetShower".localize()
        case 20 : return  "weather.heavySleetShower".localize()
        case 21 : return  "weather.snowShower".localize()
        case 22 : return  "weather.heavySnowShower".localize()
        case 23 : return  "weather.lightning".localize()
        case 24 : return  "weather.hail".localize()
        case 25 : return  "weather.thunderstorm".localize()
        case 26 : return  "weather.heavyThunderstorm".localize()
        case 27 : return  "weather.storm".localize()
        default : return  "weather.unknown".localize()
        }
    }
    
    public func getWindSpeed() -> String{
        "\(weatherWspd) km/h"
    }
    
    public func getWindDirection() -> String{
        if weatherWdir < 12.25{
            return "N"
        }
        if weatherWdir < 33.75{
            return "NNW"
        }
        if weatherWdir < 56.25{
            return "NW"
        }
        if weatherWdir < 78.75{
            return "WNW"
        }
        if weatherWdir < 101.25{
            return "W"
        }
        if weatherWdir < 123.75{
            return "WSW"
        }
        if weatherWdir < 146.25{
            return "SW"
        }
        if weatherWdir < 168.75{
            return "SSW"
        }
        if weatherWdir < 191.25{
            return "S"
        }
        if weatherWdir < 213.75{
            return "SSO"
        }
        if weatherWdir < 236.25{
            return "SO"
        }
        if weatherWdir < 258.75{
            return "OSO"
        }
        if weatherWdir < 281.25{
            return "O"
        }
        if weatherWdir < 303.75{
            return "ONO"
        }
        if weatherWdir < 326.25{
            return "NO"
        }
        if weatherWdir < 348.75{
            return "NNO"
        }
        return "N"
    }
    
    public func getTemperature() -> String{
        "\(weatherTemp) °C"
    }
    
    public func getHumidity() -> String{
        "\(weatherRhum) %"
    }
    
}

class WeatherDataList : Decodable{
    
    static var dateFormatter : DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .none
        dateFormatter.dateFormat = "yyyy-MM-dd HH:00:00"
        return dateFormatter
    }
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    var data = Array<WeatherData>()
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(Array<WeatherData>.self, forKey: .data) ?? Array<WeatherData>()
    }
    
    func getWeatherData(date: Date) -> WeatherData?{
        let dateString = WeatherDataList.dateFormatter.string(from: date)
        return data.first(where: { weatherData in
            weatherData.time == dateString
        })
    }
    
}
