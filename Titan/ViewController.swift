//
//  ViewController.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let jsonDecoder = JSONDecoder()
    
    struct DataResponse: Codable {
        let data: DataVariable
        let meta: MetaVariable
    }
    
    struct NoDataResponse: Codable {
        let meta: MetaVariable
    }
    
    struct DataVariable: Codable {
        let party_exists: Bool
    }
    
    struct MetaVariable: Codable {
        let data_count: Int
        let message: String
        let request: String
        let success: Bool
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var partyIDInput: UITextField!
    @IBOutlet weak var joinPartyButton: UIButton!
    @IBOutlet weak var errorMessageTextBox: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        LoginManager.shared.delegate = self
        self.partyIDInput.isHidden = true
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
                    let response = try self.jsonDecoder.decode(NoDataResponse.self, from: responseDict)
                    if response.meta.message == "OK" {
                        //This means that this is the first party this device is hosting.
                    } else {
                        //This device already has been registered, so no problem is this fails.
                    }
                } catch {}
            }
        }
    }
    
    @IBAction func joinPartyButtonPressed(_ sender: UIButton) {
        self.partyIDInput.isHidden = false
        self.joinPartyButton.titleLabel!.text = "Submit"
        
        if let partyId = partyIDInput.text {
            Api.shared.joinParty(partyId) { (responseDict) in
                do {
                    let response = try self.jsonDecoder.decode(DataResponse.self, from: responseDict)
                    if response.data.party_exists {
                        DispatchQueue.main.async {
                            UserDefaults.standard.register(defaults: ["partyID" : partyId])
                            self.performSegue(withIdentifier: "SearchSongSegue", sender: self)
                        }
                    } else {
                        self.errorMessageTextBox.text = "\(partyId) is not an active party."
                    }
                } catch {}
            }
        }        
    }
    
}

extension ViewController: LoginManagerDelegate {
    func loginManagerDidLoginWithSuccess() {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewNC")
        dismiss(animated: true, completion: nil)
    }
}


