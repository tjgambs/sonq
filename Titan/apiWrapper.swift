//
//  apiWrapper.swift
//  Titan
//
//  Created by Tim Gamble on 2/14/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

//: Playground - noun: a place where people can play

import UIKit
import Foundation


struct Payload: Codable {
    let party_id: String
    let song_id: String
}

func sendPayload(payload:Payload?, endpoint:String, httpMethod:String) {
    var urlComponents = URLComponents()
    urlComponents.scheme = "http"
    urlComponents.host = "0.0.0.0"
    urlComponents.port = 5000
    urlComponents.path = endpoint
    guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod
    
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["Content-Type"] = "application/json"
    request.allHTTPHeaderFields = headers
    
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(payload)
        request.httpBody = jsonData
    }
    catch {}
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request) { (responseData, response, responseError) in
        guard responseError == nil else {
            return
        }
        if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
            print(utf8Representation)
        } else {
            print("Failed")
        }
    }
    task.resume()
}


func getParties() {
    let endpoint:String = "/v1/titan/get_parties"
    let httpMethod:String = "GET"
    sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod)
}

func getSongs(_ partyId: String) {
    let endpoint:String = "/v1/titan/get_queue/" + partyId
    let httpMethod:String = "GET"
    sendPayload(payload:nil, endpoint:endpoint, httpMethod:httpMethod)
}

func addSong(_ partyId: String, _ songId: String) {
    let endpoint:String = "/v1/titan/add_song"
    let httpMethod:String = "POST"
    let payload: Payload = Payload(party_id:partyId, song_id:songId)
    sendPayload(payload:payload, endpoint:endpoint, httpMethod:httpMethod)
}

func deleteSong(_ partyId: String, _ songId: String) {
    let endpoint:String = "/v1/titan/add_song"
    let httpMethod:String = "DELETE"
    let payload: Payload = Payload(party_id:partyId, song_id:songId)
    sendPayload(payload:payload, endpoint:endpoint, httpMethod:httpMethod)
}
