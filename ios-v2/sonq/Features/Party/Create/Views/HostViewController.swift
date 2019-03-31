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
    }

    @IBAction func connectToSpotify(_ sender: Any) {
        SpotifyLogin.shared.login()
    }
}

extension HostViewController: SpotifyLoginDelegate {
    func didLoginWithSuccess() {
        DispatchQueue.main.async {
            SpotifyLogin.shared.preparePlayer()
            self.performSegue(withIdentifier: "CreateParty", sender: self)
        }
    }
}
