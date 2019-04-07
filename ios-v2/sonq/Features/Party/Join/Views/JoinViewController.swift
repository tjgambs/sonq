//
//  JoinViewController.swift
//  sonq
//
//  Created by Tim Gamble on 4/6/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation

class JoinViewController: ViewController  {
    
    @IBOutlet weak var partyIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeRightAction))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipeRightAction() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackSegue", sender: self)
        }
    }
    
    @IBAction func submitPartyId(_ sender: UIButton) {
        let partyId = partyIdTextField.text
        
        // TODO: Register this deviceID if it has not been already.
        // TODO: Check to see if the party id is valid
        // TODO: Add this deviceID to the party
        Globals.partyId = partyId
        Globals.isHost = false
        print(Globals.partyId!, Globals.deviceId!)
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "JoinParty", sender: self)
        }
    }
}
