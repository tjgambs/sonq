//
//  ViewController.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginManager.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Globals.partyDeviceId = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        if let username = usernameField.text {
            if !username.isEmpty {
                LoginManager.shared.login()
                if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                    Api.shared.updateUsername(deviceID: deviceID, username: username) { (responseDict) in
                        do {
                            let jsonDecoder = JSONDecoder()
                            let response = try jsonDecoder.decode(NoDataResponse.self, from: responseDict)
                            if response.meta.message == "OK" {
                                // OK
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "showScan", sender: self)
                                }
                            } else {
                                // Should not fail.
                            }
                        } catch {}
                    }
                }
            }
            else {
                let title = "Please Enter a Username"
                let message = "Your username cannot be blank."
                showAlert(title: title, message: message)
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let username = usernameField.text {
            if !username.isEmpty {
                LoginManager.shared.login()
                if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
                    Api.shared.updateUsername(deviceID: deviceID, username: username) { (responseDict) in
                        do {
                            let jsonDecoder = JSONDecoder()
                            let response = try jsonDecoder.decode(NoDataResponse.self, from: responseDict)
                            if response.meta.message == "OK" {
                                // OK
                            } else {
                                // Should not fail.
                            }
                        } catch {}
                    }
                }
            }
            else {
                let title = "Please Enter a Username"
                let message = "Your username cannot be blank."
                showAlert(title: title, message: message)
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
