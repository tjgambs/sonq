//
//  LoginManager.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation
import SafariServices

protocol LoginManagerDelegate: class {
    func loginManagerDidLoginWithSuccess()
}

class LoginManager {
    
    static var shared = LoginManager()
    weak var delegate: LoginManagerDelegate?
    var auth = SPTAuth.defaultInstance()!
    var safariVC: SFSafariViewController!

    private init() {
        auth.sessionUserDefaultsKey = "kCurrentSession"
        auth.redirectURL = URL(string: "Titan://returnAfterLogin")
        auth.clientID = "362fc5bdd0d5461499ccf6e4e7483800"
        auth.requestedScopes = [
            SPTAuthStreamingScope,
            SPTAuthPlaylistReadPrivateScope,
            SPTAuthPlaylistModifyPublicScope,
            SPTAuthPlaylistModifyPrivateScope]
    }
    
    var isLogged: Bool {
        if let session = session {
            return session.isValid()
        }
        return false
    }
    
    private var session: SPTSession? {
        if let sessionObject = UserDefaults.standard.object(forKey: auth.sessionUserDefaultsKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: sessionObject) as? SPTSession
        }
        return nil
    }
    
    func preparePlayer() {
        guard let session = session else { return }
        MediaPlayer.shared.configurePlayer(authSession: session, id: auth.clientID)
    }
    
    func login() {
        if !self.isLogged {
            // If they are not logged in, have them navigate to Safari to authenticate
            safariVC = SFSafariViewController(url: auth.spotifyWebAuthenticationURL())
            UIApplication.shared.keyWindow?.rootViewController?.present(
                safariVC, animated: true, completion: nil)
        } else {
            // Otherwise, just let them in to their party because they are already authorized.
            self.delegate?.loginManagerDidLoginWithSuccess()
        }
    }
    
    func handled(url: URL) -> Bool {
        guard auth.canHandle(auth.redirectURL) else {
            return false
        }
        auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
            //If we have successfully authenticated, dismiss the browser then execute whatever
            //the delegate has determined to execute on success.
            self.safariVC.dismiss(animated: false)
            self.delegate?.loginManagerDidLoginWithSuccess()
        })
        return true
    }
}
