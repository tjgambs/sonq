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

    struct NextSongResponse: Codable {
        let data: NextSong
        let meta: MetaVariable
    }
    
    struct NextSong: Codable {
        let results: Song.SongData
    }
    
    struct MetaVariable: Codable {
        let data_count: Int?
        let message: String
        let request: String
        let success: Bool
    }

    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var partyIDLabel: UILabel!
    
    let jsonDecoder = JSONDecoder()
    var nextSong: Song.SongData?
    
    var song: String!
    var artist: String!
    var imageURL: String!
    var songURL: String!
    var durationInSeconds: Double!
    
    var timeElapsed: Float = 0
    var songFinished = false
    var previousSliderValue: Float = 0
    
    var playTimer: Timer!
    var sliderTimer: Timer!
    var nextSongTimer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Wait for the API to say what song to play
        while(true) {
            if self.song != nil {
                break
            }
            sleep(1)
        }
        
        
        prepareNextSong()
        updateUserInterface()
        updatePlayButton()
        updateSlider()
        navigationItem.title = artist.uppercased()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //Update the slider and the play button once every second
        playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
        sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        nextSongTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateNextSong), userInfo: nil, repeats: true)
        
        if !MediaPlayer.shared.isPlaying {
            MediaPlayer.shared.play(track: songURL)
            MediaPlayer.shared.pause()
            playButton.image = UIImage(named: "play")
            if playTimer.isValid && sliderTimer.isValid {
                playTimer.invalidate()
                sliderTimer.invalidate()
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        playTimer.invalidate()
        sliderTimer.invalidate()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateNextSong() {
        //Just in case the queue empties at some point during the party
        if nextSong == nil && !MediaPlayer.shared.isPlaying {
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                Api.shared.getNextSong(deviceID) { (responseDict) in
                    do {
                        let response = try self.jsonDecoder.decode(NextSongResponse.self, from: responseDict)
                        self.nextSong = response.data.results
                    } catch {
                        self.nextSong = nil
                    }
                }
            }
        }
    }
    
    func updateUserInterface() {
        songName.text = song
        guard let url = URL(string: imageURL) else {
            return
        }
        do {
            let data = try Data(contentsOf: url)
            albumCoverImage.image = UIImage(data: data)
        } catch {}
        slider.isContinuous = false
    }
    
    func prepareNextSong() {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            Api.shared.deleteSong(deviceID: deviceID, songURL: self.songURL, { (r) in
                Api.shared.getNextSong(deviceID) { (responseDict) in
                    do {
                        let response = try self.jsonDecoder.decode(NextSongResponse.self, from: responseDict)
                        self.nextSong = response.data.results
                    } catch {
                        self.nextSong = nil
                    }
                }
            })
        }
    }
    
    @objc func updatePlayButton(){
        if !MediaPlayer.shared.isPlaying && slider.value == 1 {
            if let nextSong = self.nextSong {
                song = nextSong.name
                artist = nextSong.artist
                imageURL = nextSong.imageURL
                songURL = nextSong.songURL
                durationInSeconds = nextSong.durationInSeconds
                timeElapsed = 0
                songFinished = false
                previousSliderValue = 0
                slider.setValue(0, animated: true)
                updateUserInterface()                
                MediaPlayer.shared.play(track: songURL)
                playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
                sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
                navigationItem.title = artist.uppercased()
                prepareNextSong()
            } else {
                playButton.image = UIImage(named: "play")
                songFinished = true
            }
            playTimer.invalidate()
            sliderTimer.invalidate()
        } else {
            playButton.image = UIImage(named: "pause")
        }
    }
    
    @objc func updateSlider() {
        timeElapsed += 1
        slider.value = Float(timeElapsed) / Float(durationInSeconds)
    }
    
    
    @IBAction func sliderDragged(_ sender: UISlider) {
        if songFinished {
            MediaPlayer.shared.play(track: songURL)
            MediaPlayer.shared.seek(progress: slider.value, songDuration: durationInSeconds)
            songFinished = false
            if !playTimer.isValid && !sliderTimer.isValid {
                playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
                sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            }
        } else {
            MediaPlayer.shared.seek(progress: slider.value, songDuration: durationInSeconds)
        }
        timeElapsed = slider.value * Float(durationInSeconds)
    }
    
    
    @IBAction func playButtonTapped(_ sender: UITapGestureRecognizer) {
        if MediaPlayer.shared.isPlaying {
            MediaPlayer.shared.pause()
            playButton.image = UIImage(named: "play")
            if playTimer.isValid && sliderTimer.isValid {
                playTimer.invalidate()
                sliderTimer.invalidate()
            }
        } else {
            if slider.value == 1 {
                timeElapsed = 0
                MediaPlayer.shared.play(track: songURL)
            } else {
                MediaPlayer.shared.resume()
            }
            playButton.image = UIImage(named: "pause")
            if !playTimer.isValid && !sliderTimer.isValid {
                playTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updatePlayButton), userInfo: nil, repeats: true)
                sliderTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
            }
        }
    }
}
