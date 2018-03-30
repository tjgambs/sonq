//
//  AppDelegate.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if !LoginManager.shared.isLogged {
            // If the user has not logged in yet, go to login screen
            self.window?.rootViewController = UIStoryboard(
                name: "Main", bundle: nil).instantiateInitialViewController()
            self.window?.makeKeyAndVisible()
        } else {
            // Else go to the tab bar controller
            self.window?.rootViewController = UIStoryboard(
                name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.handled(url: url)
    }
    
}
