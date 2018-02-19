//
//  ApiWrapper.swift
//  Titan
//
//  Created by Tim Gamble on 2/17/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation


class Api: NSObject {
    
    static let shared = Api()
    static var JOIN_ID = ""
    
    let scheme = "http"
    let host = "35.184.31.17"
    let port = 80
    
    
    struct SongData: Codable {
        var deviceID: String
        var name: String?
        var artist: String?
        var duration: String?
        var durationInSeconds: Double?
        var imageURL: String?
        var songURL: String
    }
    
    func sendPayload(payload:SongData?, endpoint:String, httpMethod:String, completion: @escaping (Data) -> ()) {
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

    
    func getQueue(_ deviceID: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/get_queue/\(deviceID)"
        let httpMethod:String = "GET"
        sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func getNextSong(_ deviceID: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/get_next_song/\(deviceID)"
        let httpMethod:String = "GET"
        sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func addSong(deviceID: String, name: String, artist: String, duration: String, durationInSeconds: Double, imageURL:String, songURL:String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/add_song"
        let httpMethod:String = "POST"
        let payload: SongData = SongData(deviceID:deviceID, name:name, artist:artist, duration:duration, durationInSeconds: durationInSeconds, imageURL:imageURL, songURL:songURL)
        sendPayload(payload:payload, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func deleteSong(deviceID: String, songURL: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/delete_song"
        let httpMethod:String = "DELETE"
        let payload: SongData = SongData(deviceID:deviceID, name:nil, artist:nil, duration:nil, durationInSeconds: nil, imageURL:nil, songURL:songURL)
        sendPayload(payload:payload, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func registerDevice(_ deviceID: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/register_device/\(deviceID)"
        let httpMethod:String = "GET"
        sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }
    
    func joinParty(_ deviceID: String, _ completion: @escaping (Data) -> ()) {
        let endpoint:String = "/v1/titan/join_party/\(deviceID)"
        let httpMethod:String = "GET"
        sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod, completion:completion)
    }

}
