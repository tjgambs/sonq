//
//  AppDelegate.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //if user has not logged in yet, go to login screen
        if !LoginManager.shared.isLogged {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
            self.window?.makeKeyAndVisible()
        } else {
            //else go to the navigation controller
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewNC")
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.handled(url: url)
    }
    
}
