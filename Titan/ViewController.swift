//
//  ViewController.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        LoginManager.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        LoginManager.shared.login()
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            Api.shared.registerDevice(deviceID) { (responseDict) in
                do {
                    let jsonDecoder = JSONDecoder()
                    let response = try jsonDecoder.decode(NoDataResponse.self, from: responseDict)
                    if response.meta.message == "OK" {
                        // This means that this is the first party this device is hosting.
                    } else {
                        // This device already has been registered, so no problem is this fails.
                    }
                } catch {}
            }
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
}

extension ViewController: LoginManagerDelegate {
    
    func loginManagerDidLoginWithSuccess() {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TabBarController")
        dismiss(animated: true, completion: nil)
    }
    
}
