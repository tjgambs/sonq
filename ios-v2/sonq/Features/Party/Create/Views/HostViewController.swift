//
//  HostViewController.swift
//  sonq
//
//  Created by Tim Gamble on 3/31/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftRandom

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
    
    func afterRegistration() {
        Globals.partyId = Utilities.generatePartyId()
        Globals.isHost = true
        SonqAPI.postParty()
            .done { value -> Void in
                self.performSegue(withIdentifier: "CreateParty", sender: self)
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }

    func didLoginWithSuccess() {
        DispatchQueue.main.async {
            SpotifyLogin.shared.preparePlayer()
            SonqAPI.getDevice()
                .done { value -> Void in
                    let json = JSON(value)
                    Globals.deviceName = json["username"].stringValue
                    self.afterRegistration()
                }
                .catch { error in
                    // TODO: Use the Spotify username for the host instead of generating one.
                    Globals.deviceName = Randoms.randomFakeName()
                    SonqAPI.postDevice()
                        .done { value -> Void in
                            self.afterRegistration()
                        }
                        .catch { error in
                            print(error.localizedDescription)
                    }
            }
        }
    }
}
