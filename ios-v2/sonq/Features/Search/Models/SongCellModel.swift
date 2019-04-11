//
//  SongCellModel.swift
//  sonq
//
//  Created by Tim Gamble on 3/30/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class SongCellModel: UITableViewCell {
    
    @IBOutlet weak var cellSongImage: UIImageView!
    @IBOutlet weak var cellSongName: UILabel!
    @IBOutlet weak var cellSongDuration: UILabel!
    @IBOutlet weak var cellSongArtist: UILabel!
    @IBOutlet weak var cellSongAddedBy: UILabel?
    @IBOutlet weak var cellSongAlbum: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(_ viewModel: SongModel) {
        self.cellSongImage.af_setImage(withURL: URL(string: viewModel.imageURL)!)
        self.cellSongName.text = viewModel.name
        self.cellSongArtist.text = viewModel.artist
        self.cellSongDuration.text = viewModel.duration
        self.cellSongAlbum.text = viewModel.album
        if viewModel.addedBy != nil {
            self.cellSongAddedBy?.text = viewModel.addedBy
        }
    }
}
