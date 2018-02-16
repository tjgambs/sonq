//
//  JoinPartyViewController.swift
//  Titan
//
//  Created by Cody Dietrich on 2/14/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class JoinPartyViewController: UIViewController {

    let titanAPI = TitanAPI.sharedInstance
    @IBOutlet weak var partyID: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    struct Response: Codable {
        let data: DataVariable
        let meta: MetaVariable
    }
    
    struct DataVariable: Codable {
        let party_exists: Bool
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
        joinButton.layer.cornerRadius = 12
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func join(_ sender: UIButton) {
        let id = partyID.text ?? ""
        titanAPI.joinParty(id) { (responseDict) in
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(Response.self, from: responseDict)
                if response.data.party_exists {
                    TitanAPI.PARTY_ID = id
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "PartyMemberSegue", sender: self)
                    }
                }
            } catch {}
        }
    }
}

