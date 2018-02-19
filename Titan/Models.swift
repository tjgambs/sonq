//
//  Models.swift
//  Titan
//
//  Created by Tim Gamble on 2/18/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation

struct Globals {
    static var partyDeviceId: String?
}


struct SongData: Codable {
    var name: String
    var artist: String
    var duration: String
    var durationInSeconds: Double
    var imageURL: String
    var songURL: String
}

struct QueueResponse: Codable {
    var data: Queue
    var meta: MetaVariable
}

struct PostResponse: Codable {
    var meta: MetaVariable
}

struct Queue: Codable {
    var results: [SongData]
}

struct MetaVariable: Codable {
    var data_count: Int?
    var message: String
    var request: String
    var success: Bool
}


struct SongResponse: Codable {
    let data: [SongData]
    let meta: MetaVariable
}


struct NextSongResponse: Codable {
    let data: NextSong
    let meta: MetaVariable
}

struct NextSong: Codable {
    let results: SongData?
}

struct NoDataResponse: Codable {
    let meta: MetaVariable
}
