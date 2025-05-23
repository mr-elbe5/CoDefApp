/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import Foundation
import UIKit

struct RequestController {
    
    static var shared = RequestController()
    
    func hasServerURL() -> Bool{
        return !AppState.shared.serverURL.isEmpty
    }
    
    func createRequest(url : String, method: String, headerFields : [String : String]?, params : [String:String]?) -> URLRequest? {
        var body : Data?;
        if let params = params{
            do {
                body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {
                print("could not create URLRequest: parameters could not be serialized")
                return nil
            }
        }
        return createRequest(url: url, method: method, headerFields: headerFields, body: body)
    }
    
    func createRequest(url : String, method: String, headerFields : [String : String]?, body: Data?) -> URLRequest? {
        guard let requestUrl = URL(string : url) else {
            print("could not create URLRequest: URL could not be created")
            return nil
        }
        var request = URLRequest(url : requestUrl)
        request.httpMethod=method
        if let headerFields = headerFields{
            for key: String in headerFields.keys {
                if let val = headerFields[key] {
                    request.addValue(val, forHTTPHeaderField: key)
                }
            }
        }
        if let body = body{
            request.httpBody = body;
        }
        return request
    }
    
    func requestJson<T : Decodable>(url : String, withParams params : [String:String]?) async throws -> T?{
        if let urlRequest = createRequest(url: url, method: "POST", headerFields:
            ["Content-Type" : "application/json",
             "Accept" : "application/json"
        ], params: params){
            return try await self.launchJsonRequest(with: urlRequest)
        }
        return nil
    }
    
    func requestAuthorizedJson<T : Decodable>(url : String, withParams params : [String:String]?) async throws -> T?{
        if let urlRequest = createRequest(url: url, method: "POST", headerFields:[
            "Content-Type" : "application/json",
            "Accept" : "application/json",
            "Authentication" : AppState.shared.currentUser.token ?? ""
        ], params: params){
            return try await self.launchJsonRequest(with: urlRequest)
        }
        return nil
    }
    
    func requestAuthorizedImage(url : String, withParams params : [String:String]?) async throws -> UIImage?{
        if let urlRequest = createRequest(url: url, method: "POST", headerFields: [
            "Content-Type" : "application/json",
            "Accept" : "application/json",
            "Authentication" : AppState.shared.currentUser.token ?? ""
        ], params: params){
            return try await self.launchImageRequest(with: urlRequest)
        }
        return nil
    }
    
    func uploadAuthorizedImage(url : String, withImage uiImage : UIImage,fileName: String, contentType: String ) async throws -> IdResponse?{
        if let data = uiImage.jpegData(compressionQuality: 0.8) {
            if let urlRequest = createRequest(url: url, method: "POST", headerFields: [
                "Content-Type" : "application/octet-stream",
                "contentType" : contentType,
                "fileName" : fileName,
                "Accept" : "application/json",
                "Authentication" : AppState.shared.currentUser.token ?? ""
            ], body: data){
                return try await self.launchJsonRequest(with: urlRequest)
            }
        }
        return nil
    }
    
    func launchJsonRequest<T : Decodable>(with request : URLRequest) async throws -> T?{
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse{
            if response.statusCode != 200{
                Log.error("got status code \(response.statusCode)")
                return nil
            }
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .millisecondsSince1970
            let result = try decoder.decode(T.self, from: data)
            return result
        } catch let error{
            print(error)
            return nil
        }
    }
    
    func launchImageRequest(with request : URLRequest) async throws -> UIImage?{
        let (data, response) = try await URLSession.shared.data(for: request)
        if let response = response as? HTTPURLResponse{
            if response.statusCode != 200{
                Log.error("code status code \(response.statusCode)")
                return nil
            }
        }
        if let image = UIImage(data: data){
            print("image received from server")
            return image
        }
        return nil
    }
    
}



