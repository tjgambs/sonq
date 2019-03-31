//
//  QRViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit
import QRCode

class QRViewController: ViewController {
    
    @IBOutlet weak var qrCodeImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // This is a party member, not a host. Generate a QR code using the party id.
        if Globals.partyDeviceId != nil {
            var qrCode = QRCode(Globals.partyDeviceId!)
            qrCode?.color = CIColor(rgba: "ee2f64")
            qrCode?.backgroundColor = CIColor(red: 14.0/255, green: 15.0/255, blue: 38.0/255)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
            // Else this is a host, generate a QR code using this device's UUID.
        else if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            var qrCode = QRCode(deviceID)
            qrCode?.color = CIColor(rgba: "ee2f64")
            qrCode?.backgroundColor = CIColor(red: 14.0/255, green: 15.0/255, blue: 38.0/255)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
    }

}
