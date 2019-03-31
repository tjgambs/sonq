//
//  QueueViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit

class QueueViewController: ViewController {
    
    @IBOutlet weak var emptyText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emptyText.text = "The Queue is empty. Search for songs to add to the queue."
    }

}
