//
//  SpotifyLogin.swift
//  sonq
//
//  Created by Tim Gamble on 3/31/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import SafariServices

protocol SpotifyLoginDelegate: class {
    func didLoginWithSuccess()
}

class SpotifyLogin {
    
    static var shared = SpotifyLogin()
    weak var delegate: SpotifyLoginDelegate?
    var auth = SPTAuth.defaultInstance()!
    var safariVC: SFSafariViewController!
    
    private init() {
        auth.sessionUserDefaultsKey = "kCurrentSession"
        auth.redirectURL = URL(string: "sonq://returnAfterLogin")
        auth.clientID = "1df21b37504648758e66548b7aa15e11"
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
    
    func login(viewController: UIViewController) {
        if !self.isLogged {
            safariVC = SFSafariViewController(url: auth.spotifyWebAuthenticationURL())
            safariVC.modalPresentationStyle = .overFullScreen
            viewController.present(safariVC, animated: true, completion: nil)
        } else {
            self.delegate?.didLoginWithSuccess()
        }
    }
    
    func handled(url: URL) -> Bool {
        guard auth.canHandle(auth.redirectURL) else {
            return false
        }
        auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
            self.safariVC.dismiss(animated: true, completion: {
                self.delegate?.didLoginWithSuccess()
            })
        })
        return true
    }
}
