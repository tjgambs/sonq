//
//  SpotifyAuthViewController.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class SpotifyAuthViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {

    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?

    @IBOutlet weak var loginButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let redirectURL = "Titan://returnAfterLogin"
        auth.redirectURL     = URL(string: redirectURL)
        auth.clientID        = "362fc5bdd0d5461499ccf6e4e7483800"
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
        NotificationCenter.default.addObserver(self, selector: #selector(SpotifyAuthViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    @objc func updateAfterFirstLogin () {
        loginButton.isHidden = true
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        self.player?.playSpotifyURI("spotify:track:58s6EuEYJdlb0kO7awm3Vp", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            
        })
        self.navigationController!.navigationBar.isHidden = true;
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        UIApplication.shared.open(loginUrl!, options: [:], completionHandler: nil)
    }
}
