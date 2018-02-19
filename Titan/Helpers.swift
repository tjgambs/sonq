//
//  Helpers.swift
//  Titan
//
//  Created by Tim Gamble on 2/18/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import Foundation

var partyDeviceId: String?

func showAlert(title: String, message: String) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(alertAction)
    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
}
