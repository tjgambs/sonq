//
//  JoinViewController.swift
//  sonq
//
//  Created by Tim Gamble on 4/6/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftRandom

class JoinViewController: ViewController  {
    
    @IBOutlet weak var partyIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeRightAction))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        view.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(JoinViewController.dismissKeyboard)))
        self.partyIdTextField.delegate = self
    }
    
    @objc func swipeRightAction() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackSegue", sender: self)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func afterRegistration() {
        let partyId = partyIdTextField.text!
        
        SonqAPI.getParty(partyId: partyId)
            .done { value -> Void in
                let json = JSON(value)
                Globals.partyId = partyId
                
                if (json["device_id"].stringValue == Globals.deviceId!) {
                    Globals.isHost = true
                } else {
                    Globals.isHost = false
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "JoinParty", sender: self)
                }
            }
            .catch { error in
                print(error.localizedDescription)
                Utilities.showAlert(
                    viewController: self,
                    title:"Party not found",
                    message:"Please try another party id.")
        }
    }
    
    @IBAction func submitPartyId(_ sender: UIButton) {
        SonqAPI.getDevice()
            .done { value -> Void in
                let json = JSON(value)
                Globals.deviceName = json["username"].stringValue
                self.afterRegistration()
            }
            .catch { error in
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


extension JoinViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
}
