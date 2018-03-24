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
        
        // This is a party member, not a host. Generate a QR code using the party id.
        if Globals.partyDeviceId != nil {
            let qrCode = QRCode(Globals.partyDeviceId!)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
        // Else this is a host, generate a QR code using this device's UUID.
        else if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            let qrCode = QRCode(deviceID)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goHome(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "Home")
        dismiss(animated: true, completion: nil)
    }

}
