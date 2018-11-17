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
    @IBOutlet weak var cellSongArtist: UILabel!
    @IBOutlet weak var cellSongAddedBy: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(_ viewModel: SongViewModel) {
        cellSongImage.af_setImage(withURL: URL(string: viewModel.imageURL)!)
        cellSongName.text = viewModel.name
        cellSongArtist.text = viewModel.artist
        cellSongDuration.text = viewModel.duration
        if viewModel.added_by != nil {
            cellSongAddedBy.text = viewModel.added_by
        }
    }
}
