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

class Spotify {
    
    static func getAuthToken() -> Promise<[String: Any]> {
        let headers = ["Authorization": "Basic MzYyZmM1YmRkMGQ1NDYxNDk5Y2NmNmU0ZTc0ODM4MDA6ODhiNGNlOWVhMTQ2NDdjOTlkOGI0YjU3MGYxYTk5OGE="]
        
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