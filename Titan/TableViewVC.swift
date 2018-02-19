//
//  TableViewVC.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation


class TableViewVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var viewPartyButton: UIButton!
    @IBOutlet weak var partyIDHeader: UINavigationItem!
    
    var song = Song()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the previously defined AVAudioSession (in AppDelegate.swift) to active
        // Apple suggests doing it only right before your app will play audio
        // Otherwise, just opening the app the the menu screen will cancel all other audio
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("Activating AVAudioSession failed.")
        }
        
        // Login to Spotify
        LoginManager.shared.preparePlayer()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        if Globals.partyDeviceId != nil {
            self.viewPartyButton.isHidden = true
        }
    }
    
    @IBAction func displayQueueButtonClicked(_ sender: UIButton) {
        // When the user asks to see the current Queue, go get the Queue,
        // clear the search results, then update the search results with
        // the response from the server.
        if var deviceID = UIDevice.current.identifierForVendor?.uuidString {
            if Globals.partyDeviceId != nil {
                deviceID = Globals.partyDeviceId! //If this user had joined a party, add the song to the parties queue.
            }
            Api.shared.getQueue(deviceID) { (responseDict) in
                do {
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(
                        QueueResponse.self,
                        from: responseDict)
                    self.song.songArray = []
                    for s in response.data.results {
                        self.song.songArray.append(s)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print("ERROR IN displayQueueButtonClicked: \(error)")
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "tableToMusic" {
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                var response: NextSongResponse?
                Api.shared.getNextSong(deviceID) { (responseDict) in
                    do {
                        let jsonDecoder = JSONDecoder()
                        response = try jsonDecoder.decode(NextSongResponse.self, from: responseDict)
                    } catch {
                        print("ERROR IN shouldPerformSegue: \(error)")
                    }
                }
                
                // Wait for the server to respond. TEMPORARY
                while (response == nil) {
                    sleep(1)
                }
                
                // The queue has an item.
                if response!.data.results != nil {
                    return true
                }
                
                //There is nothing in the Queue, don't let them proceed.
                showAlert(title: "No song in queue",
                          message: "Add a song to the queue to get this party started!")
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MusicVC
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            if !MediaPlayer.shared.isPlaying {
                // If there is no music playing, generate the destination with the first item in the Queue.
                Api.shared.getNextSong(deviceID) { (responseDict) in
                    do {
                        let jsonDecoder = JSONDecoder()
                        let response = try jsonDecoder.decode(NextSongResponse.self, from: responseDict)
                        if let results = response.data.results {
                            destination.song = results.name
                            destination.artist = results.artist
                            destination.imageURL = results.imageURL
                            destination.songURL = results.songURL
                            destination.durationInSeconds = results.durationInSeconds
                        }
                    } catch {
                        print("ERROR IN prepare: \(error)")
                    }
                }
            } else {
                // If there is music playing, generate the destination with the song playing.
                if let player = MediaPlayer.shared.player {
                    if let currentTrack = player.metadata.currentTrack {
                        destination.song = currentTrack.name
                        destination.artist = currentTrack.artistName
                        destination.imageURL = currentTrack.albumCoverArtURL
                        destination.songURL = currentTrack.uri
                        destination.durationInSeconds = currentTrack.duration
                        destination.timeElapsed = Float(player.playbackState.position)
                    }
                }
            }
        }
    }
}


extension TableViewVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keywords = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        //Every time the searchBar is "clicked", the searchURL is updated
        song.searchURL = "https://api.spotify.com/v1/search?q=\(keywords)&type=track"
        self.view.endEditing(true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        song.getSongDetails {
            self.tableView.reloadData()
        }
        return true
    }
}


extension TableViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return song.songArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if var deviceID = UIDevice.current.identifierForVendor?.uuidString {
            if Globals.partyDeviceId != nil {
                deviceID = Globals.partyDeviceId! //If this user had joined a party, add the song to the parties queue.
            }
            let selectedSong = song.songArray[indexPath.row]
            Api.shared.addSong(
                deviceID: deviceID,
                name: selectedSong.name,
                artist: selectedSong.artist,
                duration: selectedSong.duration,
                durationInSeconds: selectedSong.durationInSeconds,
                imageURL: selectedSong.imageURL,
                songURL: selectedSong.songURL) { (responseDict) in
                    let json = JSON(responseDict)
                    if json["meta"]["message"] == "OK" {
                        DispatchQueue.main.async {

                            // TODO: This is where a green check mark should show up.

                        }
                    } else {
                        let title = "Song Already in Queue"
                        let message = "This Song is already in the queue. Please wait for the song to finish before adding it again."
                        showAlert(title: title, message: message)
                    }
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        let selectedSong = song.songArray[indexPath.row]
        cell.cellSongName.text = selectedSong.name
        cell.cellSongDuration.text = selectedSong.duration
        cell.cellSongArtist.text = selectedSong.artist
        guard let url = URL(string: selectedSong.imageURL) else {
            return cell //Don't bother continuing, the resrt has to do with the image.
        }
        do {
            let data = try Data(contentsOf: url)
            cell.cellSongImage.image = UIImage(data: data)
        } catch {}
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
