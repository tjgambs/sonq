//
//  PlayerViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit

class PlayerViewController: ViewController {

    @IBOutlet weak var albumArt: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var durationEndLabel: UILabel!
    @IBOutlet weak var durationCurrentLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    
    var renderedSong: SongModel?
    var currentSong: SongModel? {
        if let song = MediaPlayer.shared.currentSong {
            return song
        }
        return nil
    }
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.durationSlider.addTarget(
            self,
            action: #selector(sliderDidEndSliding),
            for: ([.touchUpInside,.touchUpOutside]))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.currentSong != nil && self.renderedSong != nil {
            if self.currentSong?.songURL != self.renderedSong?.songURL {
                self.renderSong(self.currentSong!)
            }
        } else if self.currentSong != nil {
            self.renderSong(self.currentSong!)
        } else {
            self.clearSong()
        }
        if MediaPlayer.shared.isPlaying {
            self.enableTimer()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disableTimer()
    }
    
    @objc func updateCurrentDuration() -> Void {
        if let player = MediaPlayer.shared.player {
            if let state = player.playbackState {
                self.durationCurrentLabel.text = state.position.minuteSecondMS
                if self.currentSong != nil {
                    self.durationSlider.value = Float(Double(state.position) / self.currentSong!.durationInSeconds)
                }
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.disableTimer()
    }
    
    @objc func sliderDidEndSliding() {
        if self.currentSong != nil {
            MediaPlayer.shared.seek(
                progress: self.durationSlider.value,
                songDuration: self.currentSong!.durationInSeconds)
        }
        self.enableTimer()
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        // TODO: Get the next song in the queue, then play that
    }
    
    @IBAction func playPauseButtonPressed(_ sender: UIButton) {
        if MediaPlayer.shared.isPlaying {
            MediaPlayer.shared.pause()
            self.playPauseButton.setImage(
                UIImage(named: "play-button"), for: UIControl.State.normal)
            self.disableTimer()
        } else {
            if MediaPlayer.shared.currentSong != nil {
                MediaPlayer.shared.resume()
                self.playPauseButton.setImage(
                    UIImage(named: "pause-button"), for: UIControl.State.normal)
                self.enableTimer()
            } else {
                // TODO: Handle condition when there is no music in the queue. Maybe alert them?
            }
        }
    }
    
    func renderSong(_ song: SongModel) {
        self.albumArt.af_setImage(withURL: URL(string: song.imageURL)!)
        self.songNameLabel.text = song.name
        self.songArtistLabel.text = song.artist
        self.durationEndLabel.text = song.duration
        if MediaPlayer.shared.isPlaying {
            self.playPauseButton.setImage(
                UIImage(named: "pause-button"), for: UIControl.State.normal)
        } else {
            self.playPauseButton.setImage(
                UIImage(named: "play-button"), for: UIControl.State.normal)
        }
        self.renderedSong = song
    }
    
    func clearSong() {
        self.albumArt.image = nil
        self.songNameLabel.text = ""
        self.songArtistLabel.text = ""
        self.durationEndLabel.text = "0:00"
        self.durationCurrentLabel.text = "0:00"
        self.playPauseButton.setImage(
            UIImage(named: "play-button"), for: UIControl.State.normal)
        self.renderedSong = nil
    }
    
    func disableTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer = nil
        }
    }
    
    func enableTimer() {
        if self.timer == nil {
            self.updateCurrentDuration()
            self.timer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(self.updateCurrentDuration),
                userInfo: nil,
                repeats: true)
        }
    }
}
