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

    fileprivate let songViewModelController = SongViewModelController()
    var selectedCells = [IndexPath]()
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
                
        super.viewDidLoad()

        // Login to Spotify
        LoginManager.shared.preparePlayer()
        
        // Initialize the components
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        //Load initial suggestions
        songViewModelController.getSuggestedSongs {
            self.tableView.reloadData()
        }
    }
}

extension TableViewVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Remove Refresh view, Disable selection of songs, hide edit toolbar.
        let keywords = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        // Every time the searchBar is "clicked", the searchURL is updated
        songViewModelController.searchURL = "https://api.spotify.com/v1/search?q=\(keywords)&type=track"
        self.view.endEditing(true)
        self.selectedCells = []
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.text! != "" {
            songViewModelController.getSongDetails {
                self.tableView.reloadData()
            }
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            songViewModelController.clearSearchResults()
            tableView.reloadData()
        }
    }
    
}


extension TableViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songViewModelController.numInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Get device UUID, set partyID to that. If joined a party, then switch it to the right ID.
        // deviceID is sent with who requested the song.
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            var partyID = deviceID
            if Globals.partyDeviceId != nil {
                // If this user had joined a party, add the song to the parties queue.
                partyID = Globals.partyDeviceId!
            }
            let selectedSong = songViewModelController.viewModel(section: indexPath.section, index: indexPath.row)
            Api.shared.addSong(
                partyID: partyID,
                name: selectedSong.name,
                artist: selectedSong.artist,
                duration: selectedSong.duration,
                durationInSeconds: selectedSong.durationInSeconds,
                imageURL: selectedSong.imageURL,
                songURL: selectedSong.songURL,
                addedBy: deviceID) { (responseDict) in
                    let json = JSON(responseDict)
                    if json["meta"]["message"] == "OK" {
                        self.selectedCells.append(indexPath)
                        DispatchQueue.main.async {
                            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
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
        let viewModel = songViewModelController.viewModel(section: indexPath.section, index: indexPath.row)
        cell.configure(viewModel)
        cell.accessoryType = .none
        for s in selectedCells {
            if s == indexPath {
                cell.accessoryType = .checkmark
            }
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Suggested Songs"
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

}

