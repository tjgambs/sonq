//
//  Networking.swift
//  sonq
//
//  Created by Tim Gamble on 3/30/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class Spotify {
    
    static func getAuthToken() -> Promise<[String: Any]> {
        let headers = ["Authorization": "Basic MWRmMjFiMzc1MDQ2NDg3NThlNjY1NDhiN2FhMTVlMTE6ZDkxMzBmOGNmMjQxNDU1Nzk2ZDJhNjA4YmIwZGEzN2U="]
        
        return Promise { seal in
            Alamofire.request(
                "https://accounts.spotify.com/api/token",
                method: .post,
                parameters: ["grant_type": "client_credentials"],
                encoding: URLEncoding.default,
                headers: headers)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func getSearchResults(searchURL: String, accessToken: String) -> Promise<[String: Any]> {
        return Promise { seal in
            Alamofire.request(
                searchURL,
                method: .get,
                parameters: ["q":"", "type":"track"],
                encoding: URLEncoding.default,
                headers: ["Authorization": "Bearer " + accessToken])
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
}

class SonqAPI {
    
    static let baseURL = "http://192.168.1.16:5000"
    
    static func postDevice() -> Promise<[String: Any]> {
        let parameters = [
            "id": Globals.deviceId!,
            "username": Globals.deviceName!
        ]
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/device",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func getDevice() -> Promise<[String: Any]> {
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/device/" + Globals.deviceId!,
                method: .get,
                encoding: URLEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func postGuest() -> Promise<[String: Any]> {
        let parameters = [
            "party_id": Globals.partyId!,
            "device_id": Globals.deviceId!
        ]
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/guests",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func deleteGuest() -> Promise<[String: Any]> {
        let parameters = [
            "party_id": Globals.partyId!,
            "device_id": Globals.deviceId!
        ]
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/guests",
                method: .delete,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func postParty() -> Promise<[String: Any]> {
        let parameters = [
            "id": Globals.partyId!,
            "created_by": Globals.deviceId!,
            "name": ""
        ]
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/party",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func getParty(partyId: String) -> Promise<[String: Any]> {
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/party/" + partyId,
                method: .get,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func deleteParty() -> Promise<[String: Any]> {
        let parameters = [
            "id": Globals.partyId!
        ]
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/party",
                method: .delete,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func postQueue(song: SongModel) -> Promise<[String: Any]> {
        let parameters = [
            "party_id": Globals.partyId!,
            "name": song.name,
            "artist": song.artist,
            "album": song.album,
            "duration": song.duration,
            "duration_in_seconds": String(song.durationInSeconds),
            "image_url": song.imageURL,
            "song_url": song.songURL,
            "added_by": Globals.deviceId!
        ]
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/queue",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String: Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
    static func getQueue() -> Promise<[[String: Any]]> {
        return Promise { seal in
            Alamofire.request(
                SonqAPI.baseURL + "/sonq/queue/" + Globals.partyId!,
                method: .get,
                encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [[String: Any]] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        seal.fulfill(json)
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
    }
    
}
