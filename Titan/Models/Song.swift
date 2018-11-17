//
//  Song.swift
//  Titan
//
//  Created by Cody Dietrich on 3/27/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

struct Song {
    
    let name: String
    let artist: String
    let durationInMS: Double
    let imageURL: String
    let songURL: String
    
    init (name: String, artist: String, duration: Double,
          imageURL: String, songURL: String) {
        self.name = name
        self.artist = artist
        self.durationInMS = duration
        self.imageURL = imageURL
        self.songURL = songURL
    }
}
