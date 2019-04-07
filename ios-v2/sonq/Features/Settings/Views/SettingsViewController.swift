//
//  SettingsViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController {

    @IBOutlet weak var endLeavePartyLabel: UILabel!
    @IBOutlet weak var endLeavePartyDescriptionLabel: UILabel!
    @IBOutlet weak var endLeaveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (Globals.isHost != nil && Globals.isHost!) {
            endLeavePartyLabel.text = "End Party"
            endLeavePartyDescriptionLabel.text = "Ending the party will clear the queue and remove all party guests."
            endLeaveButton.setTitle("End Party", for: .normal)
        } else {
            endLeavePartyLabel.text = "Leave Party"
            endLeavePartyDescriptionLabel.text = "Leaving the party will prevent you from contributing to the queue."
            endLeaveButton.setTitle("Leave Party", for: .normal)
        }
    }

    @IBAction func endParty(_ sender: UIButton) {
        if (Globals.isHost != nil && Globals.isHost!) {
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
        } else {
            let alert = UIAlertController(
                title: "Leave Party?",
                message: "Leaving the party will prevent you from contributing to the queue.",
                preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Leave Party", style: .destructive, handler: { (_) in
                Globals.partyId = nil
                self.performSegue(withIdentifier: "EndParty", sender: self)
            }))
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            self.present(alert, animated: true)
        }
        
    }
}
