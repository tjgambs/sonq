//
//  SongCell.swift
//  Titan
//
//  Created by Tim Gamble on 2/7/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class SongCell: UITableViewCell {
    
    @IBOutlet weak var cellSongImage: UIImageView!
    @IBOutlet weak var cellSongName: UILabel!
    @IBOutlet weak var cellSongDuration: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

}
