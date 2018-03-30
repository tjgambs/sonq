//
//  MusicVC.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import AVFoundation

class MusicVC: UIViewController {

    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var skipButton: UIButton!
    
    let jsonDecoder = JSONDecoder()
    
    var song: String! = ""
    var artist: String! = ""
    var imageURL: String! = ""
    var songURL: String! = ""
    var durationInSeconds: Double! = 0.0
    
    var timeElapsed: Float = 0
    var songFinished: Bool = false
    
    var playTimer: Timer!
    var sliderTimer: Timer!
    var nextSongTimer: Timer!
    
    var resumeNotAllowed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Globals.partyDeviceId != nil {
            // Only the host can adjust the player.
            self.slider.isHidden = true
            self.playButton.isHidden = true
            self.skipButton.isHidden = true
            self.songName.text = "Sorry, only the host can adjust the music."
            return
        }
        
        // When the view is first loaded and a song is currently playing, update the interface.
        if MediaPlayer.shared.isPlaying {
            // Update the interface with the information for the current song.
            if let player = MediaPlayer.shared.player {
                if let currentTrack = player.metadata.currentTrack {
                    self.song = currentTrack.name
                    self.artist = currentTrack.artistName
                    self.imageURL = currentTrack.albumCoverArtURL
                    self.songURL = currentTrack.uri
                    self.durationInSeconds = currentTrack.duration
                    self.timeElapsed = Float(player.playbackState.position)
                }
            }
            self.updateUserInterface()
            playTimer = Timer.scheduledTimer(
                timeInterval: 1, target: self,
                selector: #selector(updatePlayButton),
                userInfo: nil, repeats: true)
            sliderTimer = Timer.scheduledTimer(
                timeInterval: 1, target: self,
                selector: #selector(updateSlider),
                userInfo: nil, repeats: true)
            self.updatePlayButton()
            self.updateSlider()
        } else {
            // When there is no music playing, then go get the next song
            self.getNextSong(playOnceReceived: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initTimers() {
        self.playTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(self.updatePlayButton),
            userInfo: nil, repeats: true)
        self.sliderTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(self.updateSlider),
            userInfo: nil, repeats: true)
    }
    
    func initNextSongTimer() {
        self.nextSongTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(self.handleNextSongTimer),
            userInfo: nil, repeats: true)
    }
    
    @objc func handleNextSongTimer() {
        self.getNextSong(playOnceReceived: true)
    }

    func getNextSong(playOnceReceived: Bool) {
        if let partyID = UIDevice.current.identifierForVendor?.uuidString {
            Api.shared.getNextSong(partyID) { (responseDict) in
                do {
                    let response = try self.jsonDecoder.decode(
                        NextSongResponse.self, from: responseDict)
                    if let nextSong = response.data.results {
                        DispatchQueue.main.async {
                            self.song = nextSong.name
                            self.artist = nextSong.artist
                            self.imageURL = nextSong.imageURL
                            self.songURL = nextSong.songURL
                            self.durationInSeconds = nextSong.durationInSeconds
                            self.timeElapsed = 0
                            self.songFinished = true
                            self.slider.setValue(0, animated: true)
                            if playOnceReceived {
                                MediaPlayer.shared.play(track: self.songURL)
                                self.initTimers()
                            }
                            self.updateUserInterface()
                            self.updatePlayButton()
                            if let x = self.nextSongTimer {
                                x.invalidate()
                            }
                            self.resumeNotAllowed = false
                        }
                    } else {
                        if let playlist = Globals.defaultPlaylist {
                            if playlist.name! != "None" {
                                let auth = SPTAuth.defaultInstance()!
                                SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: auth.session.accessToken) { (error, snap) in
                                    if let s = snap as? SPTPlaylistSnapshot {
                                        if let items = s.firstTrackPage.items {
                                            if Globals.defaultPlaylistIndex! > items.count - 1 {
                                                Globals.defaultPlaylistIndex = 0
                                            }
                                            let defaultSong = items[Globals.defaultPlaylistIndex!] as! SPTPlaylistTrack
                                            Globals.defaultPlaylistIndex = Globals.defaultPlaylistIndex! + 1
                                            Api.shared.addSong(
                                                partyID: partyID,
                                                name: defaultSong.name,
                                                artist: (defaultSong.artists[0] as! SPTPartialArtist).name!,
                                                duration: defaultSong.duration.minuteSecondMS,
                                                durationInSeconds: defaultSong.duration,
                                                imageURL: defaultSong.album.largestCover.imageURL!.absoluteString,
                                                songURL: defaultSong.playableUri!.absoluteString,
                                                addedBy: partyID) { (responseDict) in
                                                    self.getNextSong(playOnceReceived: playOnceReceived)
                                                    self.playTimer.invalidate()
                                                    self.sliderTimer.invalidate()
                                            }
                                        } else {
                                           self.endPlayer()
                                        }
                                    } else {
                                        self.endPlayer()
                                    }
                                }
                            } else {
                                self.endPlayer()
                            }
                        } else {
                            self.endPlayer()
                        }
                    }
                } catch {
                    print("There was an error in getNextSong()")
                }
            }
        }
    }
    
    func endPlayer() {
        // There aren't any more songs in the queue.
        // Also, we want to turn off the music playing if there is any.
        DispatchQueue.main.async {
            self.song = ""
            self.artist = ""
            self.imageURL = ""
            self.songURL = ""
            self.durationInSeconds = 0.0
            self.timeElapsed = 0
            self.songFinished = false
            self.slider.setValue(1, animated: true)
            self.updateUserInterface()
            self.playButton.image = UIImage(named: "play")
            if self.nextSongTimer == nil || !self.nextSongTimer.isValid {
                self.initNextSongTimer()
            }
            // We don't allow the play button to be tapped during this time.
            self.resumeNotAllowed = true
        }
    }
    
    func updateUserInterface() {
        self.songName.text = song
        guard let url = URL(string: self.imageURL) else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            self.albumCoverImage.image = UIImage(data: data)
        } catch {}
        self.slider.isContinuous = false
    }

    @objc func updatePlayButton() {
        if !MediaPlayer.shared.isPlaying && slider.value == 1 {
            // If there is no music playing and the slider is at the end, then go get
            // the next song in the queue and invalidate the timers.
            if let partyID = UIDevice.current.identifierForVendor?.uuidString {
                Api.shared.deleteSong(partyID: partyID, songURL: self.songURL, { (r) in
                    self.getNextSong(playOnceReceived: true)
                    self.playTimer.invalidate()
                    self.sliderTimer.invalidate()
                })
            }
        } else if !MediaPlayer.shared.isPlaying {
            // If the slider is not at the end and no music is playing, then this
            // means that the party hasn't started yet so display the play button.
            self.playButton.image = UIImage(named: "play")
            self.songFinished = true
        } else {
            self.playButton.image = UIImage(named: "pause")
        }
    }
    
    @objc func updateSlider() {
        self.timeElapsed += 1
        self.slider.value = Float(self.timeElapsed) / Float(self.durationInSeconds)
    }
    
    @IBAction func sliderDragged(_ sender: UISlider) {
        if resumeNotAllowed {
            return
        }
        MediaPlayer.shared.seek(
            progress: self.slider.value,
            songDuration: self.durationInSeconds)
        self.timeElapsed = self.slider.value * Float(self.durationInSeconds)
    }
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        if resumeNotAllowed {
            return
        }
        if let partyID = UIDevice.current.identifierForVendor?.uuidString {
            // When the skip button is pressed, delete the current song and start
            // playing the next song. Invalidate the play and slider timers.
            Api.shared.deleteSong(partyID: partyID, songURL: self.songURL, { (r) in
                MediaPlayer.shared.pause()
                self.getNextSong(playOnceReceived: true)
                self.playTimer.invalidate()
                self.sliderTimer.invalidate()
            })
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UITapGestureRecognizer) {
        if resumeNotAllowed {
            return
        }
        if MediaPlayer.shared.isPlaying {
            // If there is music playing and this function is run, then we want
            // to pause the music, set the image to play and invalidate the timers.
            MediaPlayer.shared.pause()
            playButton.image = UIImage(named: "play")
            playTimer.invalidate()
            sliderTimer.invalidate()
        } else if MediaPlayer.shared.player?.metadata == nil {
            // If music has never been started, then we want to start the music from
            // the beginning. We then initalize the timers and set the image to pause.
            MediaPlayer.shared.play(track: self.songURL)
            self.initTimers()
            self.playButton.image = UIImage(named: "pause")
        } else {
            // If there was no music playing but there was music playing before, then
            // resume the music.
            MediaPlayer.shared.resume()
            self.initTimers()
            self.playButton.image = UIImage(named: "pause")
        }
    }
    
    @IBAction func goHome(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(
            name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToPlayer(segue: UIStoryboardSegue) {}
    
}
