//
//  SongModel.swift
//  sonq
//
//  Created by Tim Gamble on 3/30/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import SwiftyJSON

class SongModel {
    
    let id: Int?
    let name: String
    let artist: String
    let durationInMS: Double
    let durationInSeconds: Double
    let duration: String
    let imageURL: String
    let songURL: String
    let addedBy: String?
    let album: String
    let deviceID: String?
    
    init(json: JSON, addedBy: String?, fromAPI: Bool) {
        if (fromAPI) {
            self.id = json["id"].intValue
            self.name = json["name"].stringValue
            self.album = json["album"].stringValue
            self.artist = json["artist"].stringValue
            self.durationInMS = json["duration_in_ms"].doubleValue
            self.durationInSeconds = json["duration_in_seconds"].doubleValue
            self.duration = json["duration"].stringValue
            self.imageURL = json["image_url"].stringValue
            self.songURL = json["song_url"].stringValue
            self.addedBy = json["added_by"].stringValue
            self.deviceID = json["device_id"].stringValue
        } else {
            self.id = nil
            self.name = json["name"].stringValue
            self.album = json["album"]["name"].stringValue
            self.artist = json["album"]["artists"][0]["name"].stringValue
            self.durationInMS = json["duration_ms"].doubleValue
            self.durationInSeconds = Double(self.durationInMS) / 1000
            self.duration = self.durationInSeconds.minuteSecondMS
            self.imageURL = json["album"]["images"][0]["url"].stringValue
            self.songURL = json["uri"].stringValue
            self.addedBy = addedBy
            self.deviceID = nil
        }
    }
}


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
