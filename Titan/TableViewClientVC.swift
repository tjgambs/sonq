//
//  TableViewClientVC.swift
//  Titan
//
//  Created by Cody Dietrich on 2/18/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class TableViewClientVC: UIViewController {
    
    let jsonDecoder = JSONDecoder()
    let partyID = Api.JOIN_ID
    
    struct QueueResponse: Codable {
        let data: Queue
        let meta: MetaVariable
    }
    
    struct PostResponse: Codable {
        let meta: MetaVariable
    }
    
    struct Queue: Codable {
        let results: [Song.SongData]
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
    
    @IBAction func displayQueueButtonClicked(_ sender: UIButton) {
        Api.shared.getQueue(partyID) { (responseDict) in
            do {
                let response = try self.jsonDecoder.decode(QueueResponse.self, from: responseDict)
                self.song.songArray = []
                for s in response.data.results {
                    self.song.songArray.append(s)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {print("ERROR IN displayQueueButtonClicked: \(error)")}
        }
    }
}

extension TableViewClientVC: UISearchBarDelegate {
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

extension TableViewClientVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return song.songArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let name = song.songArray[indexPath.row].name
        let artist = song.songArray[indexPath.row].artist
        let imageURL = song.songArray[indexPath.row].imageURL
        let songURL = song.songArray[indexPath.row].songURL
        let durationInSeconds = song.songArray[indexPath.row].durationInSeconds
        let duration = song.songArray[indexPath.row].duration
        Api.shared.addSong(deviceID:partyID, name:name, artist:artist, duration:duration, durationInSeconds:durationInSeconds, imageURL:imageURL, songURL:songURL) { (responseDict) in
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
            } catch {print("ERROR IN tableView: \(error)")}
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        
        cell.cellSongName.text = song.songArray[indexPath.row].name
        cell.cellSongDuration.text = song.songArray[indexPath.row].duration
        cell.cellSongArtist.text = song.songArray[indexPath.row].artist
        
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
