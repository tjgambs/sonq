//
//  Utilities.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation

class Utilities {
    
    static func generatePartyId() -> String {
        let length = 8
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func showAlert(viewController: ViewController, title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
