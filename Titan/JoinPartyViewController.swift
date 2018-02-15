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
        titanAPI.joinParty(id) { (responseDict) in
            print(responseDict)
            if let dataDict = responseDict["data"] as? [String: Any] {
                if let validParty = dataDict["party_exists"] as? Bool {
                    if validParty {
                        print("VALID PARTY")
                        TitanAPI.PARTY_ID = id
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "PartyMemberSegue", sender: self)
                        }
                    }
                    else {
                        print("INVALID PARTY")
                    }
                }
            }
        }
    }
}

