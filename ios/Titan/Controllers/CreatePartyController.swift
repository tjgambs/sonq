//
//  CreatePartyController.swift
//  Titan
//
//  Created by Tim Gamble on 6/9/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class CreatePartyController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // When the user presses outside of the keyboard, dismiss the keeyboard.
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(CreatePartyController.dismissKeyboard)))
        
        // Set the delegates
        self.usernameField.delegate = self
        LoginManager.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Globals.partyDeviceId = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // When the user presses the return button, dismiss the keyboard.
        self.dismissKeyboard()
        return false
    }
    
    @objc func dismissKeyboard() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    
    @IBAction func createPartyButtonPressed(_ sender: UIButton) {
        // Register the party with this device being the host.
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
            } else {
                // If the user does not input a user name, alert them with a warning.
                let title = "Please Enter a Username"
                let message = "Your username cannot be blank."
                showAlert(title: title, message: message)
            }
        }
    }
}

extension CreatePartyController: LoginManagerDelegate {
    
    func loginManagerDidLoginWithSuccess() {
        DispatchQueue.main.async {
            // Segue to the CreateParty View
            self.performSegue(withIdentifier: "CreateParty", sender: self)  
        }
    }
    
}
