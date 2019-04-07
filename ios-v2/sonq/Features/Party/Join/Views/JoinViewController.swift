//
//  JoinViewController.swift
//  sonq
//
//  Created by Tim Gamble on 4/6/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation

class JoinViewController: ViewController  {
    
    @IBOutlet weak var partyIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeRight = UISwipeGestureRecognizer(
            target: self,
            action: #selector(swipeRightAction))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func swipeRightAction() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackSegue", sender: self)
        }
    }
    
    @IBAction func submitPartyId(_ sender: UIButton) {
        // TODO: Check and make sure this party id is legit
    }
}
