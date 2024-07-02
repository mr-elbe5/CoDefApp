/*
 Construction Defect Tracker
 App for tracking construction defects
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit
import E5Data

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
            let url = "https://nominatim.openstreetmap.org/search?country=\(country.toURL())&city=\(city.toURL())&street=\(street.toURL())&format=json&limit=1"
            if let nominatimRequest = RequestController.shared.createRequest(url: url, method: "GET", headerFields: [:], params: nil){
                if let location: NominatimLocation = try await launchJsonRequest(with: nominatimRequest){
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
    
    static func launchJsonRequest(with request : URLRequest) async throws -> NominatimLocation?{
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse{
            if response.statusCode != 200{
                Log.error("got status code \(response.statusCode)")
                return nil
            }
        }
        let decoder = JSONDecoder()
        if var jsonString = String(data: data, encoding: .utf8){
            // remove array
            jsonString.removeFirst()
            jsonString.removeLast()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            return NominatimLocation.fromJSON(encoded: jsonString)
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
