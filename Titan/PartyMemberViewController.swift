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
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var searchBox: UITextField!

    @IBOutlet weak var searchResults: UIStackView!
    
    var searchResultButtons: [UIButton] = []
    
    struct Response: Codable {
        let data: [Song]
        let meta: MetaVariable
    }
    
    struct Song: Codable {
        let name:String
        let uri:String
        let artist:String
    }
    
    struct MetaVariable: Codable {
        let data_count: Int
        let message: String
        let request: String
        let success: Bool
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        welcomeLabel.text = "Welcome to Party \(TitanAPI.PARTY_ID)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func buttonAction(sender: UIButton!) {
        print(sender.titleLabel!.text ?? "")
    }
    
    func createButton(_ song: Song) -> UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 15))
        button.backgroundColor = .green
        button.setTitle(song.name + " - " + song.artist, for: [])
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        return button
    }
    
    @IBAction func searchSong(_ sender: UIButton) {
        let text = searchBox.text ?? ""
        titanAPI.searchSong(text) { (responseDict) in
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(Response.self, from: responseDict)
                DispatchQueue.main.async {
                    for b in self.searchResultButtons {
                        self.searchResults.removeArrangedSubview(b)
                    }
                }
                for song in response.data {
                    DispatchQueue.main.async {
                        let button = self.createButton(song)
                        self.searchResultButtons.append(button)
                        self.searchResults.addArrangedSubview(button)
                    }
                }
            } catch {}
           
        }
    }
    
}


