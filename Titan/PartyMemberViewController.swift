//
//  PartyMemberViewController.swift
//  Titan
//
//  Created by Cody Dietrich on 2/14/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class PartyMemberViewController: UIViewController {
    
    let titanAPI = TitanAPI.sharedInstance
    let jsonDecoder = JSONDecoder()
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var searchBox: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchResults: UIStackView!
    
    //var searchResultButtons: [UIButton] = []
    
    var searchResultButtons = [UIButton : String]()
    
    struct SongResponse: Codable {
        let data: [Song]
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
        let results: [String]
    }
    
    struct Song: Codable {
        let name:String
        let uri:String
        let artist:String
    }
    
    struct MetaVariable: Codable {
        let data_count: Int?
        let message: String
        let request: String
        let success: Bool
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        welcomeLabel.text = "Welcome to Party \(TitanAPI.PARTY_ID)"
        searchButton.layer.cornerRadius = 12
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonAction(sender: UIButton!) {
        let uri = searchResultButtons[sender] ?? "NULL"
        print((sender.titleLabel!.text ?? "") + " - URI: \(uri)")
        titanAPI.addSong(TitanAPI.PARTY_ID, uri) { (responseDict) in
            do {
                let response = try self.jsonDecoder.decode(PostResponse.self, from: responseDict)
                let message = response.meta.message
                if message == "OK" {
                    DispatchQueue.main.async {
                        self.searchResults.removeArrangedSubview(sender)
                    }
                }
                else {
                    self.showAlert(title: "Song Already in Queue", message: "This Song is already in the queue. Please wait for the song to finish before adding it again.")
                }
                
            } catch {}
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getCurrentQueue() -> [String] {
        var currQueue = [String]()
        titanAPI.getSongs(TitanAPI.PARTY_ID) { (responseDict) in
            do {
                let response = try self.jsonDecoder.decode(QueueResponse.self, from: responseDict)
                currQueue = response.data.results
            } catch {}
        }
        return currQueue
    }
    
    func createButton(_ song: Song) -> UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 15))
        button.backgroundColor = .lightGray
        button.setTitle(song.name + " - " + song.artist, for: [])
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        return button
    }
    
    @IBAction func searchSong(_ sender: UIButton) {
        let text = searchBox.text ?? ""
        titanAPI.searchSong(text) { (responseDict) in
            do {
                let response = try self.jsonDecoder.decode(SongResponse.self, from: responseDict)
                DispatchQueue.main.async {
                    for b in self.searchResultButtons.keys {
                        self.searchResults.removeArrangedSubview(b)
                    }
                }
                for song in response.data {
                    DispatchQueue.main.async {
                        let button = self.createButton(song)
                        self.searchResultButtons[button] = song.uri
                        self.searchResults.addArrangedSubview(button)
                    }
                }
            } catch {}
        }
    }
}


