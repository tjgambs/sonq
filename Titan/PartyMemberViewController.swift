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
    @IBAction func searchSong(_ sender: UIButton) {
        let text = searchBox.text ?? ""
        titanAPI.searchSong(text) { (responseDict) in
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(Response.self, from: responseDict)
                for song in response.data {
                    //TODO - Create buttons based on the Song object.
                    print(song.name)
                }
            } catch {}
           
        }
    }
    
}


