//
//  Song.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON


class SongViewModelController {
    
    fileprivate var viewModels:[[SongViewModel]] = [[],[]]
    
    let auth = SPTAuth.defaultInstance()!
    var suggestIDArray = [String]()
    var searchURL: String!
    var accessToken: String?
    var updateAuthTimer: Timer!
    
    public init() {
        updateAuthorization()
        updateAuthTimer = Timer.scheduledTimer(
            timeInterval: 1800, target: self,
            selector: #selector(updateAuthorization),
            userInfo: nil, repeats: true)
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
        let headers = ["Authorization": "Bearer " + accessToken!]
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
                        var searchSongs = [Song]()
                        for item in JSONSongsArray.arrayValue {
                            searchSongs.append(
                                Song(name: item["name"].stringValue,
                                        artist: item["album"]["artists"][0]["name"].stringValue,
                                        duration: item["duration_ms"].doubleValue,
                                        imageURL: item["album"]["images"][0]["url"].stringValue,
                                        songURL: item["uri"].stringValue
                                        )
                            )
                        }
                        self.viewModels[0] = SongViewModelController.initViewModels(searchSongs)
                        self.getSuggestedSongs(callback: callback)
                    case .failure(let error):
                        print("ERROR: \(error) failed to get data from url \(self.searchURL)")
                }
        }
    }
    
    func getSuggestedSongs(callback: @escaping () -> ()) {
        var suggestURL = "https://api.spotify.com/v1/recommendations?limit=5&seed_tracks="
        if var partyID = UIDevice.current.identifierForVendor?.uuidString {
            if Globals.partyDeviceId != nil {
                partyID = Globals.partyDeviceId!
            }
            Api.shared.getQueue(partyID) { (responseDict) in
                do {
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(
                        QueueResponse.self,
                        from: responseDict)
                    self.suggestIDArray = []
                    for s in response.data.results.prefix(5) {
                        let songID = s.songURL.split(separator: ":").last
                        self.suggestIDArray.append(String(songID!))
                    }
                    suggestURL = suggestURL + self.suggestIDArray.joined(separator: ",")
                    if (self.accessToken == nil) {
                        // NEED A BETTER SOLUTION
                        sleep(1)
                    }
                    let headers = ["Authorization": "Bearer " + self.accessToken!]
                    Alamofire.request(
                        suggestURL,
                        method: .get,
                        parameters: nil,
                        encoding: URLEncoding.default,
                        headers: headers).responseJSON { response in
                            switch response.result {
                                case .success(let value):
                                    let json = JSON(value)
                                    let JSONSongsArray = json["tracks"]
                                    var suggestSongs = [Song]()
                                    for track in JSONSongsArray.arrayValue {
                                        suggestSongs.append(
                                            Song(name: track["name"].stringValue,
                                                 artist: track["album"]["artists"][0]["name"].stringValue,
                                                 duration: track["duration_ms"].doubleValue,
                                                 imageURL: track["album"]["images"][0]["url"].stringValue,
                                                 songURL: track["uri"].stringValue
                                            )
                                        )
                                    }
                                    self.viewModels[1] = SongViewModelController.initViewModels(suggestSongs)
                                    callback()
                                case .failure(let error):
                                    print("ERROR: \(error) failed to get data from url \(suggestURL)")
                            }
                            
                    }
                    
                } catch {}
            }
        }
    }
    
    func getQueue(partyID: String, callback: @escaping () -> ()) {
        Api.shared.getQueue(partyID) { (responseDict) in
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(
                    QueueResponse.self,
                    from: responseDict)
                var queueSongs = [Song]()
                var addedByArray = [String]()
                for s in response.data.results {
                    let duration = s.durationInSeconds * 1000
                    queueSongs.append(Song(name: s.name,
                                           artist: s.artist,
                                           duration: duration,
                                           imageURL: s.imageURL,
                                           songURL: s.songURL))
                    addedByArray.append(s.added_by ?? "")
                }
                self.viewModels[0] = SongViewModelController.initViewModels(queueSongs, addedByArray)
                callback()
            } catch {
                print("ERROR IN updateQueue: \(error)")
            }
        }
    }
    
    func numInSection(section: Int) -> Int {
        return viewModels[section].count
    }
    
    func viewModel(section: Int, index: Int) -> SongViewModel {
        return viewModels[section][index]
    }
    
    func deleteModel(section: Int, index: Int) {
        viewModels[section].remove(at: index)
    }
    
    func moveModel(oldSection: Int, oldIndex: Int, newSection: Int, newIndex: Int) {
        let toMove = viewModels[oldSection].remove(at: oldIndex)
        viewModels[newSection].insert(toMove, at: newIndex)
    }
    
    func returnModels(section: Int) -> [SongViewModel] {
        return viewModels[section]
    }
}

private extension SongViewModelController {
    static func initViewModels(_ songs: [Song], _ added_by: [String]? = nil) -> [SongViewModel] {
        if added_by == nil {
            return songs.map { song in
                return SongViewModel(song: song, added: nil)
            }
        }
        else {
            var queueModel = [SongViewModel]()
            for (song, name) in zip(songs, added_by!) {
                queueModel.append(SongViewModel(song: song, added: name))
            }
            return queueModel
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

