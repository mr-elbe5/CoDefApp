/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

class WeatherStation : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case id
    }
    
    var id: String = ""
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
    }
    
    static func getWeatherStation(country: String, city: String, street: String, meteoStatKey: String) async throws -> WeatherStation?{
        if !AppData.shared.serverSettings.meteoStatKey.isEmpty{
            if let nominatimRequest = RequestController.shared.createRequest(url: "https://nominatim.openstreetmap.org/search", method: "GET",
                                                                             headerFields: [:],
                                                                             params: ["country" : country, "city" : city, "street" : street, "format" : "json", "limit" : "1"]){
                if let location: NominatimLocation = try await RequestController.shared.launchJsonRequest(with: nominatimRequest){
                    let url = "https://meteostat.p.rapidapi.com/stations/nearby?lat=\(String(location.latitude))&lon=\(String(location.longitude))&limit=1"
                    if let stationRequest = RequestController.shared.createRequest(url: url, method: "GET", headerFields: ["X-RapidApi-Key" : meteoStatKey], params: nil){
                        if let stationList: WeatherStationList = try await RequestController.shared.launchJsonRequest(with: stationRequest), !stationList.data.isEmpty{
                            return stationList.data[0]
                        }
                    }
                    Log.debug("\(location.latitude),\(location.longitude)")
                }
            }
            
        }
        return nil
    }
    
}

class WeatherStationList : Decodable{
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
    var data = Array<WeatherStation>()
    
    init(){
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent(Array<WeatherStation>.self, forKey: .data) ?? Array<WeatherStation>()
    }
    
}
