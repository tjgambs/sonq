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

class TableViewVC: UIViewController {
    
    let jsonDecoder = JSONDecoder()
    
    struct SongResponse: Codable {
        let data: [SongData]
        let meta: MetaVariable
    }
    
    struct QueueResponse: Codable {
        let data: Queue
        let meta: MetaVariable
    }
    
    struct PostResponse: Codable {
        let meta: MetaVariable
    }
    
    struct Queue: Codable {
        let results: [SongData]
    }
    
    struct SongData: Codable {
        var deviceID: String
        var name: String
        var artist: String
        var duration: String
        var durationInSeconds: Double
        var imageURL: String
        var songURL: String
    }
    
    struct MetaVariable: Codable {
        let data_count: Int?
        let message: String
        let request: String
        let success: Bool
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var partyIDHeader: UINavigationItem!
    
    var song = Song()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //log into audio streaming
        LoginManager.shared.preparePlayer()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func partyIDButtonClicked(_ sender: UIButton) {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            self.showAlert(title:"Your Party ID:", message:deviceID)
        }
    }
}

extension TableViewVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let search = searchBar.text
        let keywords = search?.replacingOccurrences(of: " ", with: "+")
        
        //every time the searchBar is "clicked", the searchURL is updated
        song.searchURL = "https://api.spotify.com/v1/search?q=\(keywords!)&type=track"
        
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
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            let name = song.songArray[indexPath.row].name
            let artist = song.songArray[indexPath.row].artist
            let imageURL = song.songArray[indexPath.row].imageURL
            let songURL = song.songArray[indexPath.row].songURL
            let durationInSeconds = song.songArray[indexPath.row].durationInSeconds
            let duration = song.songArray[indexPath.row].duration
            Api.shared.addSong(deviceID:deviceID, name:name, artist:artist, duration:duration, durationInSeconds:durationInSeconds, imageURL:imageURL, songURL:songURL) { (responseDict) in
                do {
                    let response = try self.jsonDecoder.decode(PostResponse.self, from: responseDict)
                    let message = response.meta.message
                    if message == "OK" {
                        DispatchQueue.main.async {

                            //This is where a green check mark should show up.

                        }
                    }
                    else {
                        self.showAlert(title: "Song Already in Queue", message: "This Song is already in the queue. Please wait for the song to finish before adding it again.")
                    }
                } catch {}
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        
        cell.cellSongName.text = song.songArray[indexPath.row].name
        cell.cellSongDuration.text = song.songArray[indexPath.row].duration
        
        //get image from imageURL
        guard let url = URL(string: song.songArray[indexPath.row].imageURL) else {
            return cell //presumably returns cell without image
        }
        
        do {
            let data = try Data(contentsOf: url)
            cell.cellSongImage.image = UIImage(data: data)
        } catch {
            print("ERROR: error thrown trying to get data from URL \(url)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

