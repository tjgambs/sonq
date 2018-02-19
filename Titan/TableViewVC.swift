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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var partyIDHeader: UINavigationItem!
    
    var song = Song()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Login to Spotify
        LoginManager.shared.preparePlayer()
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
    }
    
    @IBAction func displayQueueButtonClicked(_ sender: UIButton) {
        // When the user asks to see the current Queue, go get the Queue,
        // clear the search results, then update the search results with
        // the response from the server.
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
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
            var response: NextSongResponse?
            if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                Api.shared.getNextSong(deviceID) { (responseDict) in
                    do {
                        let jsonDecoder = JSONDecoder()
                        response = try jsonDecoder.decode(NextSongResponse.self, from: responseDict)
                    }catch {
                        print("ERROR IN shouldPerformSegue: \(error)")
                    }
                }
                while (response == nil) {
                    sleep(1)
                }
                //okay to force unwrap because of loop above
                if response!.data.results != nil {
                    return true
                }
                else {
                    showAlert(title: "No song in queue", message: "Add a song to the queue to get this party started!")
                    return false
                }
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MusicVC
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            if !MediaPlayer.shared.isPlaying {
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
                destination.song = MediaPlayer.shared.player?.metadata.currentTrack?.name
                destination.artist = MediaPlayer.shared.player?.metadata.currentTrack?.artistName
                destination.imageURL = MediaPlayer.shared.player?.metadata.currentTrack?.albumCoverArtURL
                destination.songURL = MediaPlayer.shared.player?.metadata.currentTrack?.uri
                destination.durationInSeconds = MediaPlayer.shared.player?.metadata.currentTrack?.duration
                destination.timeElapsed = Float((MediaPlayer.shared.player?.playbackState.position)!) 
            }
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
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(PostResponse.self, from: responseDict)
                    let message = response.meta.message
                    if message == "OK" {
                        DispatchQueue.main.async {

                            //This is where a green check mark should show up.

                        }
                    }
                    else {
                        showAlert(title: "Song Already in Queue", message: "This Song is already in the queue. Please wait for the song to finish before adding it again.")
                    }
                } catch {print("ERROR IN tableView: \(error)")}
            }
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

