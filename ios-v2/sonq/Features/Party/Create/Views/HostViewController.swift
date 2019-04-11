//
//  HostViewController.swift
//  sonq
//
//  Created by Tim Gamble on 3/31/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation

class HostViewController: ViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpotifyLogin.shared.delegate = self
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeRightAction))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func swipeRightAction() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackSegue", sender: self)
        }
    }

    @IBAction func connectToSpotify(_ sender: Any) {
        SpotifyLogin.shared.login(viewController: self)
    }
}

extension HostViewController: SpotifyLoginDelegate {
    func didLoginWithSuccess() {
        DispatchQueue.main.async {
            SpotifyLogin.shared.preparePlayer()
            Globals.partyId = Utilities.generatePartyId()
            Globals.isHost = true
            Globals.deviceName = "Host"
                
            // TODO: Register this deviceID if it has not been already.
            // TODO: Create a party with this partyID for this deviceID
            print(Globals.partyId!, Globals.deviceId!)
                
            self.performSegue(withIdentifier: "CreateParty", sender: self)
        }
    }
}
