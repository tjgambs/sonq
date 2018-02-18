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
        
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            var qrCode = QRCode(deviceID)
            qrCode?.size = CGSize(width: 300, height: 300)
            self.qrCodeImage.image = UIImageView(qrCode: qrCode!).image
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
