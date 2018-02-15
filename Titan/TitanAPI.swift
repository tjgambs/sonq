//
//  TitanAPI.swift
//  Titan
//
//  Created by Tim Gamble on 2/14/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

class TitanAPI: NSObject {
    
    static let sharedInstance = TitanAPI()
    static var PARTY_ID = ""
    
    let scheme = "http"
    let host = "0.0.0.0"
    let port = 5000
    
    struct Payload: Codable {
        let party_id: String
        let song_id: String
    }

    func sendPayload(payload:Payload?, endpoint:String, httpMethod:String, completion: @escaping (Data) -> ()) {
        var urlComponents = URLComponents()
        urlComponents.scheme = self.scheme
        urlComponents.host = self.host
        urlComponents.port = self.port
        urlComponents.path = endpoint
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = httpMethod
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {}
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                return
            }
            if let data = responseData {
                completion(data)
            }
        }
        task.resume()
    }


    func getParties(_ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/get_parties"
        let httpMethod:String = "GET"
        return sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }

    func getSongs(_ partyId: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/get_queue/\(partyId)"
        let httpMethod:String = "GET"
        return sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }

    func addSong(_ partyId: String, _ songId: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/add_song"
        let httpMethod:String = "POST"
        let payload: Payload = Payload(party_id:partyId, song_id:songId)
        sendPayload(payload:payload, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }

    func deleteSong(_ partyId: String, _ songId: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/add_song"
        let httpMethod:String = "DELETE"
        let payload: Payload = Payload(party_id:partyId, song_id:songId)
        sendPayload(payload:payload, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func joinParty(_ partyId: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/join_party/\(partyId)"
        let httpMethod:String = "GET"
        sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func searchSong(_ text: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/spotify_search/\(text)"
        let httpMethod:String = "GET"
        sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
}
