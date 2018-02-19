//
//  QRCodeVC.swift
//  Titan
//
//  Created by Tim Gamble on 2/18/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import QRCode


class QRCodeVC: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate a QR code using this device's UUID.
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            let qrCode = QRCode(deviceID)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
