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
    @IBOutlet weak var partIdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Globals.partyId != nil {
            self.partIdLabel.text = Globals.partyId!
            var qrCode = QRCode(Globals.partyId!)
            qrCode?.color = CIColor(rgba: "ee2f64")
            qrCode?.backgroundColor = CIColor(red: 14.0/255, green: 15.0/255, blue: 38.0/255)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
    }

}
