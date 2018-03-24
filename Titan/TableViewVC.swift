//
//  TableViewVC.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation


class TableViewVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var song = Song()
    var songCellArray = [SongCell]()
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets the previously defined AVAudioSession (in AppDelegate.swift) to active
        // Apple suggests doing it only right before your app will play audio
        // Otherwise, just opening the app the the menu screen will cancel all other audio
        // Only the hosts current music is cut when entering this view because clients won't be
        // able to play the music from their devices.
        if Globals.partyDeviceId == nil {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
            } catch {
                print("Activating AVAudioSession failed.")
            }
        }
        
        // Login to Spotify
        LoginManager.shared.preparePlayer()
        
        // Initialize the components
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    @IBAction func goHome(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "Home")
            dismiss(animated: true, completion: nil)
    }
    
}

extension TableViewVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Remove Refresh view, Disable selection of songs, hide edit toolbar.
        let keywords = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        // Every time the searchBar is "clicked", the searchURL is updated
        song.searchURL = "https://api.spotify.com/v1/search?q=\(keywords)&type=track"
        self.view.endEditing(true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        song.getSongDetails {
            self.songCellArray = []
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
                // If this user had joined a party, add the song to the parties queue.
                deviceID = Globals.partyDeviceId!
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
                            self.songCellArray[indexPath.row].accessoryType = UITableViewCellAccessoryType.checkmark
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
        cell.accessoryType = UITableViewCellAccessoryType.none
        guard let url = URL(string: selectedSong.imageURL) else {
            songCellArray.append(cell)
            // Don't bother continuing, the rest has to do with the image.
            return cell
        }
        do {
            let data = try Data(contentsOf: url)
            cell.cellSongImage.image = UIImage(data: data)
        } catch {}
        songCellArray.append(cell)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

