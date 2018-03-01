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
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var viewQueue: UIButton!
    @IBOutlet weak var viewPartyButton: UIBarButtonItem!
    @IBOutlet weak var partyIDHeader: UINavigationItem!
    
    var song = Song()
    var songCellArray = [SongCell]()
    var previousSongs = [SongData]()
    var viewingQueue = false
    
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
        
        // Only the party host can view the party
        if Globals.partyDeviceId != nil {
            self.viewPartyButton.isEnabled = false
        }
    }
    
    func updateQueue() {
        // Whenever we update the Queue, we keep track of what is currently in the search
        // results. We will use this to go back if the user selects the Search button.
        if var deviceID = UIDevice.current.identifierForVendor?.uuidString {
            if Globals.partyDeviceId != nil {
                // If this user had joined a party, add the song to the parties queue.
                deviceID = Globals.partyDeviceId!
            }
            Api.shared.getQueue(deviceID) { (responseDict) in
                do {
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(
                        QueueResponse.self,
                        from: responseDict)
                    if self.previousSongs.count == 0 {
                        for s in self.song.songArray {
                            self.previousSongs.append(s)
                        }
                    }
                    self.song.songArray = []
                    for s in response.data.results {
                        self.song.songArray.append(s)
                    }
                    self.viewingQueue = true
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } catch {
                    print("ERROR IN updateQueue: \(error)")
                }
            }
        }
    }
    
    @objc func refreshQueue(_ sender: Any) {
        self.updateQueue()
    }
    
    func switchToSearch() {
        self.viewQueue.setTitle("View Queue", for: .normal)
        tableView.setEditing(false, animated: true)
        self.editButton.isHidden = true
        self.editButton.setTitle("Edit", for: .normal)
        self.tableView.refreshControl = nil
        self.tableView.allowsSelection = true
    }
    
    @IBAction func displayQueueButtonClicked(_ sender: UIButton) {
        if self.viewQueue.titleLabel?.text == "Search" {
            // If the button that was clicked was the Search button, revert the user
            // back to their previous search results stored in the previousSongs list.
            self.switchToSearch()
            self.song.songArray = []
            for s in self.previousSongs {
                self.song.songArray.append(s)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } else {
            // If the button that was clicked was the View Queue button, replace the data
            // in the search results with the current queue.
            self.viewQueue.setTitle("Search", for: .normal)
            if Globals.partyDeviceId == nil {
                // Only the host can edit the queue
                self.editButton.isHidden = false
            }
            // Add refresh view.
            if #available(iOS 10.0, *) {
                tableView.refreshControl = refreshControl
            } else {
                tableView.addSubview(refreshControl)
            }
            refreshControl.addTarget(self, action: #selector(refreshQueue(_:)), for: .valueChanged)
            self.tableView.allowsSelection = false
            self.updateQueue()
        }
    }
}


extension TableViewVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Remove Refresh view, Disable selection of songs, hide edit toolbar.
        self.switchToSearch()
        self.previousSongs = []
        let keywords = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        // Every time the searchBar is "clicked", the searchURL is updated
        song.searchURL = "https://api.spotify.com/v1/search?q=\(keywords)&type=track"
        self.view.endEditing(true)
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        song.getSongDetails {
            self.songCellArray = []
            self.viewingQueue = false
            self.tableView.reloadData()
        }
        return true
    }
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        if let title = sender.currentTitle {
            if title == "Edit" {
                tableView.setEditing(true, animated: true)
                self.editButton.setTitle("Done", for: .normal)
            } else {
                tableView.setEditing(false, animated: true)
                self.editButton.setTitle("Edit", for: .normal)
            }
        }
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
    
    // Swipe to delete cell. Check that the action is delete, the user is the host, and they are viewing the queue then delete song and cell.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && Globals.partyDeviceId == nil && viewingQueue {
            // Send delete request
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                Api.shared.deleteSong(deviceID: deviceID, songURL: song.songArray[indexPath.row].songURL) { (response) in
                    let json = JSON(response)
                    if json["meta"]["message"] == "OK" {
                        // Delete the cell
                        self.song.songArray.remove(at: indexPath.row)
                        self.songCellArray.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    } else {
                        let title = "Song Could Not Be Deleted"
                        let message = "This song is no longer in the queue"
                        showAlert(title: title, message: message)
                    }
                }
            }
        }
    }
    
    // Do not show delete option on swipe if the user is not the host and viewing the queue.
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if viewingQueue && Globals.partyDeviceId == nil && tableView.isEditing{
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCell = songCellArray[sourceIndexPath.row]
        let movedSong = song.songArray[sourceIndexPath.row]
        songCellArray.remove(at: sourceIndexPath.row)
        song.songArray.remove(at: sourceIndexPath.row)
        songCellArray.insert(movedCell, at: destinationIndexPath.row)
        song.songArray.insert(movedSong, at: destinationIndexPath.row)
        var newQueue = [String]()
        for song in song.songArray {
            newQueue.append(song.songURL)
        }
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            Api.shared.reorderQueue(deviceID: deviceID, songs: newQueue) { (response) in
                let json = JSON(response)
                if json["meta"]["message"] == "OK" {
                    // Do nothing reorder successful
                } else {
                    // Should never happen!!!!
                    let title = "Rearranging Queue Failed"
                    let message = "The songs could not be rearranged"
                    showAlert(title: title, message: message)
                }
            }
        }
    }
}

