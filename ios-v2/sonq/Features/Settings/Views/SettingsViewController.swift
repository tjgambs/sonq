//
//  SettingsViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func endParty(_ sender: Any) {
        let alert = UIAlertController(
            title: "End Party?",
            message: "Ending the party will clear the queue and remove all party guests.",
            preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "End Party", style: .destructive, handler: { (_) in
            Globals.partyId = nil
            MediaPlayer.shared.endParty()
            self.performSegue(withIdentifier: "EndParty", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(alert, animated: true)
    }
}
