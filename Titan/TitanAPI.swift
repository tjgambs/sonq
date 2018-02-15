//
//  TitanAPI.swift
//  Titan
//
//  Created by Cody Dietrich on 2/14/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//


class TitanAPI: NSObject {
    let baseURL = "75.102.253.63"
    static let sharedInstance = TitanAPI()
    //static let deleteSongEndpoint = "/delete_song/"
    //static let getPartiesEndpoint = "/get_parties/"
    //static let getQueueEndpoint = "/get_queue/"
    
    func addSong<T : Encodable>(song: T, completion:((Error?) -> Void)?){
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = baseURL
        urlComponents.port = 5000
        urlComponents.path = "/v1/titan/add_song"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(song)
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            completion?(error)
        }
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
}
