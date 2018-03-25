//
//  Song.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class Song {
    
    let auth = SPTAuth.defaultInstance()!
    var songArray = [SongData]()
    var searchURL: String!
    var accessToken: String?
    
    var updateAuthTimer: Timer!
    
    public init() {
        self.updateAuthorization()
        updateAuthTimer = Timer.scheduledTimer(timeInterval: 1800, target: self, selector: #selector(updateAuthorization), userInfo: nil, repeats: true)
    }
    
    @objc func updateAuthorization() {
        // This function allows anyone to be able to search for songs.
        let headers = ["Authorization": "Basic MzYyZmM1YmRkMGQ1NDYxNDk5Y2NmNmU0ZTc0ODM4MDA6ODhiNGNlOWVhMTQ2NDdjOTlkOGI0YjU3MGYxYTk5OGE="]
        let para = ["grant_type": "client_credentials"]
        let url = "https://accounts.spotify.com/api/token"
        Alamofire.request(
            url,
            method: .post,
            parameters: para,
            encoding: URLEncoding.default,
            headers : headers).responseJSON { response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        self.accessToken = json.dictionary!["access_token"]?.stringValue
                case .failure(let error):
                    print(error)
                }
        }
    }

    // Whenever the searchURL changes, collect the search results from the Spotify API.
    func getSongDetails(callback: @escaping () -> ()) {
        if (searchURL == nil) {
            return
        }
        let param = ["q":"", "type":"track"]
        
        let headers = ["Authorization": "Bearer " + self.accessToken!]
        Alamofire.request(
            searchURL,
            method: .get,
            parameters: param,
            encoding: URLEncoding.default,
            headers: headers).responseJSON { response in
                switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        let JSONSongsArray = json["tracks"]["items"]
                        let numberOfSongs = JSONSongsArray.count

                        // If the query returns no results, display an alert.
                        if numberOfSongs == 0 {
                            let title = "No search results found"
                            let message = "Please try another search keyword."
                            showAlert(title:title, message:message)
                            return
                        }
                        
                        // If the query returns results, clear what is currently
                        // shown then add the results.
                        self.songArray = []
                        for item in JSONSongsArray.arrayValue {
                            let durationInMS = item["duration_ms"].doubleValue
                            let durationInSeconds = Double(durationInMS) / 1000
                            let duration = durationInSeconds.minuteSecondMS
                            self.songArray.append(
                                SongData(name: item["name"].stringValue,
                                        artist: item["album"]["artists"][0]["name"].stringValue,
                                        duration: duration,
                                        durationInSeconds: durationInSeconds,
                                        imageURL: item["album"]["images"][0]["url"].stringValue,
                                        songURL: item["uri"].stringValue,
                                        added_by: nil
                                        )
                            )
                        }
                    case .failure(let error):
                        print("ERROR: \(error) failed to get data from url \(self.searchURL)")
                }
            callback()
        }
    }
}

//Expand the functionality of a time interval allowing to get a string that looks like 1:23.
extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d", minute, second)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
}


extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

