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
    
    let jsonDecoder = JSONDecoder()
    
    var song: String! = ""
    var artist: String! = ""
    var imageURL: String! = ""
    var songURL: String! = ""
    var durationInSeconds: Double! = 0.0
    
    var timeElapsed: Float = 0
    var songFinished: Bool = false
    var previousSliderValue: Float = 0
    
    var playTimer: Timer!
    var sliderTimer: Timer!
    var nextSongTimer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
            sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
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
        self.playTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                              selector: #selector(self.updatePlayButton),
                                              userInfo: nil, repeats: true)
        self.sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                                selector: #selector(self.updateSlider),
                                                userInfo: nil, repeats: true)
    }
    
    func initNextSongTimer() {
        self.nextSongTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                                  selector: #selector(self.handleNextSongTimer),
                                                  userInfo: nil, repeats: true)
    }
    
    @objc func handleNextSongTimer() {
        self.getNextSong(playOnceReceived: true)
    }

    func getNextSong(playOnceReceived: Bool) {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            Api.shared.getNextSong(deviceID) { (responseDict) in
                do {
                    let response = try self.jsonDecoder.decode(NextSongResponse.self, from: responseDict)
                    if let nextSong = response.data.results {
                        DispatchQueue.main.async {
                            self.song = nextSong.name
                            self.artist = nextSong.artist
                            self.imageURL = nextSong.imageURL
                            self.songURL = nextSong.songURL
                            self.durationInSeconds = nextSong.durationInSeconds
                            self.timeElapsed = 0
                            self.songFinished = true
                            self.previousSliderValue = 0
                            self.slider.setValue(0, animated: true)
                            if playOnceReceived {
                                MediaPlayer.shared.play(track: self.songURL)
                                self.initTimers()
                            }
                            self.updateUserInterface()
                            self.updatePlayButton()
                            self.updateSlider()
                            if let x = self.nextSongTimer {
                                x.invalidate()
                            }
                        }
                    } else {
                        // There aren't any more songs in the queue.
                        DispatchQueue.main.async {
                            self.playButton.image = UIImage(named: "play")
                            self.songFinished = true
                            if self.nextSongTimer == nil || !self.nextSongTimer.isValid {
                                self.initNextSongTimer()
                            }
                        }
                    }
                } catch {
                    // There aren't any more songs in the queue.
                    DispatchQueue.main.async {
                        self.playButton.image = UIImage(named: "play")
                        self.songFinished = true
                        if self.nextSongTimer == nil || !self.nextSongTimer.isValid {
                            self.initNextSongTimer()
                        }
                    }
                }
            }
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
    

    @objc func updatePlayButton(){
        if !MediaPlayer.shared.isPlaying && slider.value == 1 {
            // If there is no music playing and the slider is at the end, then go get the next song in the queue.
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                Api.shared.deleteSong(deviceID: deviceID, songURL: self.songURL, { (r) in
                    self.getNextSong(playOnceReceived: true)
                    self.playTimer.invalidate()
                    self.sliderTimer.invalidate()
                })
            }
        } else if !MediaPlayer.shared.isPlaying {
            // If the slider is not at the end and no music is playing, then this means that the party hasn't
            // started yet so display the play button.
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
        if self.songFinished {
            MediaPlayer.shared.play(track: self.songURL)
            MediaPlayer.shared.seek(progress: self.slider.value, songDuration: self.durationInSeconds)
            self.songFinished = false
            if !self.playTimer.isValid && !self.sliderTimer.isValid {
                self.initTimers()
            }
        } else {
            MediaPlayer.shared.seek(progress: self.slider.value, songDuration: self.durationInSeconds)
        }
        self.timeElapsed = self.slider.value * Float(self.durationInSeconds)
    }
    
    @IBAction func playButtonTapped(_ sender: UITapGestureRecognizer) {
        if MediaPlayer.shared.isPlaying {
            // If the music is playing, then pause it and invalidate the timers.
            MediaPlayer.shared.pause()
            playButton.image = UIImage(named: "play")
            if playTimer.isValid && sliderTimer.isValid {
                playTimer.invalidate()
                sliderTimer.invalidate()
            }
        } else {
            // If the music has never been started, start the music for the first time.
            if MediaPlayer.shared.player?.metadata == nil {
                MediaPlayer.shared.play(track: self.songURL)
                self.initTimers()
            } else {
                // If the music is not playing, then resume the music.
                MediaPlayer.shared.resume()
                if !self.playTimer.isValid && !self.sliderTimer.isValid {
                    self.initTimers()
                }
            }
            self.playButton.image = UIImage(named: "pause")
        }
    }
}
