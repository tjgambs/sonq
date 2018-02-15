//
//  JoinPartyViewController.swift
//  Titan
//
//  Created by Cody Dietrich on 2/14/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class JoinPartyController: UIViewController {

    let titanAPI = TitanAPI.sharedInstance
    @IBOutlet weak var partyID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func join(_ sender: UIButton) {
        let id = partyID.text ?? ""
        let song = Song(party_id: id, song_id: id)
        titanAPI.addSong(song: song) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
}

