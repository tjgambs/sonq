//
//  SongViewModel.swift
//  Titan
//
//  Created by Cody Dietrich on 3/27/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

struct SongViewModel {
    let name: String
    let artist: String
    let durationInSeconds: Double
    let duration: String
    let imageURL: String
    let songURL: String
    let added_by: String?
    
    
    
    
    init(song: Song, added: String?) {
        name = song.name
        artist = song.artist
        durationInSeconds = Double(song.durationInMS) / 1000
        duration = durationInSeconds.minuteSecondMS
        imageURL = song.imageURL
        songURL = song.songURL
        added_by = added
    }
}
