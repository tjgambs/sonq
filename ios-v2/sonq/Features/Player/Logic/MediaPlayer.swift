//
//  MediaPlayer.swift
//  sonq
//
//  Created by Tim Gamble on 3/31/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import AVFoundation

class MediaPlayer: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    static let shared = MediaPlayer()
    
    var player: SPTAudioStreamingController?
    var currentSong: SongModel?
    
    var isPlaying: Bool {
        if let player = player,
            let state = player.playbackState {
            return state.isPlaying
        }
        return false
    }
    
    func configurePlayer(authSession: SPTSession, id: String) {
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try? player!.start(withClientId: id)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func endParty() {
        currentSong = nil
        self.pause()
    }
    
    func play(song: SongModel) {
        self.currentSong = song
        SonqAPI.putQueue(song: song, status: 1)
            .done { value -> Void in }
            .catch { error in print(error.localizedDescription)
        }
        
        player?.playSpotifyURI(song.songURL, startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if let error = error {
                print("There was an error playing the track \(song.songURL), this is the error: \(error)")
            }
        })
    }
    
    func resume() {
        player?.setIsPlaying(true, callback: { (error) in
            if let error = error {
                print("Couldn't resume play. Here's the error: \(error)")
            }
        })
    }
    
    func pause() {
        player?.setIsPlaying(false, callback: { (error) in
            if let error = error {
                print("Something went wrong trying to pause the track. Here's the error: \(error)")
            }
        })
    }
    
    func seek(progress: Float, songDuration: Double) {
        player?.seek(to: Double(progress) * songDuration, callback: { (error) in
            if let error = error {
                print("Something went wrong trying to seek the track. Here's the error: \(error)")
            }
        })
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("Signed into AudioStreaming!")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Wasn't able to sign into AudioStreaming: \(String(describing: error))")
    }
}
