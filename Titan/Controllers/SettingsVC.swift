//
//  SettingsVC.swift
//  Titan
//
//  Created by Tim Gamble on 3/29/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var defaultPlaylistPicker: UIPickerView!
    var privatePlaylists: [SPTPartialPlaylist] = [SPTPartialPlaylist]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.defaultPlaylistPicker.delegate = self
        self.defaultPlaylistPicker.dataSource = self
        if let playlist = Globals.defaultPlaylist {
            playlistLabel.text = playlist.name
        } else {
            playlistLabel.text = "None"
        }
        updatePlaylists()
    }
    
    func updatePlaylists() {
        let auth = SPTAuth.defaultInstance()!
        SPTPlaylistList.playlists(forUser: auth.session.canonicalUsername, withAccessToken: auth.session.accessToken , callback: {
            (error, results)->Void in
            if (error != nil) {
                print(error!)
            } else {
                let playlists = results as! SPTListPage
                var row = 0
                let defaultPlaylist = SPTPartialPlaylist()
                defaultPlaylist.setValue("None", forKey: "name")
                self.privatePlaylists.append(defaultPlaylist)
                for (index, playlist) in playlists.items.enumerated() {
                    let p = playlist as! SPTPartialPlaylist
                    if p.name == Globals.defaultPlaylist?.name {
                        row = index + 1
                    }
                    self.privatePlaylists.append(p)
                }
                self.defaultPlaylistPicker.reloadAllComponents()
                self.defaultPlaylistPicker.selectRow(row, inComponent: 0, animated: false)
            }
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return privatePlaylists.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: privatePlaylists[row].name!, attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 14.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        playlistLabel.text = privatePlaylists[row].name!
        Globals.defaultPlaylist = privatePlaylists[row]
        Globals.defaultPlaylistIndex = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
