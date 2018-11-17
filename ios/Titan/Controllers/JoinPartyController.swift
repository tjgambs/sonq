//
//  JoinPartyController.swift
//  Titan
//
//  Created by Tim Gamble on 6/9/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class JoinPartyController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var partyIdInput: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // When the user presses outside of the keyboard, dismiss the keeyboard.
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(JoinPartyController.dismissKeyboard)))
        
        // Set the delegates
        self.partyIdInput.delegate = self
        self.usernameField.delegate = self
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if let username = usernameField.text {
            if !username.isEmpty {
                return true;
            }
        }
        let title = "Please Enter a Username"
        let message = "Your username cannot be blank."
        showAlert(title: title, message: message)
        return false;
    }
    
    func registerUser() {
        if let username = usernameField.text {
            if !username.isEmpty {
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
                let title = "Please Enter a Username"
                let message = "Your username cannot be blank."
                showAlert(title: title, message: message)
            }
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        if let partyid = partyIdInput.text {
            if partyid.isEmpty {
                let title = "Missing a Party ID"
                let message = "Either scan a Party QR or enter a Party ID."
                showAlert(title: title, message: message)
                return;
            }
            
            //*****************************************************************//
            //*******// TODO: Confirm the party id to be a real Party //*******//
            //*****************************************************************//
            
            Globals.partyDeviceId = partyid;
            registerUser()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "JoinPartyFromID", sender: self)
            }
        }
        
    }
    
}
