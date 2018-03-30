//
//  QueueViewVC.swift
//  Titan
//
//  Created by Tim Gamble on 3/23/18.
//  Copyright © 2018 Tim Gamble. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation


class QueueViewVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    fileprivate let songViewModelController = SongViewModelController()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Login to Spotify
        LoginManager.shared.preparePlayer()
        
        // Initialize the components
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        if Globals.partyDeviceId != nil {
            // Only the host can edit the queue
            self.editButton.isHidden = true
        }
        
        // Add refresh view.
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshQueue(_:)), for: .valueChanged)
        self.tableView.allowsSelection = false
        self.updateQueue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load queue each time the user views it
        updateQueue()
    }
    
    func updateQueue() {
        if var partyID = UIDevice.current.identifierForVendor?.uuidString {
            if Globals.partyDeviceId != nil {
                // If this user had joined a party, add the song to the parties queue.
                partyID = Globals.partyDeviceId!
            }
            songViewModelController.getQueue(partyID: partyID) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func refreshQueue(_ sender: Any) {
        self.updateQueue()
        self.refreshControl.endRefreshing()
    }
}


extension QueueViewVC: UISearchBarDelegate {
    
    @IBAction func editButtonClicked(_ sender: UIButton) {
        if let title = sender.currentTitle {
            if title == "Edit" {
                tableView.setEditing(true, animated: true)
                self.editButton.setTitle("Done", for: .normal)
            } else {
                tableView.setEditing(false, animated: true)
                self.editButton.setTitle("Edit", for: .normal)
            }
        }
    }
}


extension QueueViewVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songViewModelController.numInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
        let viewModel = songViewModelController.viewModel(section: indexPath.section, index: indexPath.row)
        cell.configure(viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Swipe to delete cell. Check that the action is delete, the user is the host, and they are viewing the queue then delete song and cell.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && Globals.partyDeviceId == nil {
            // Send delete request
            if let partyID = UIDevice.current.identifierForVendor?.uuidString {
                let url = songViewModelController.viewModel(section: indexPath.section, index: indexPath.row).songURL
                Api.shared.deleteSong(partyID: partyID, songURL: url) { (response) in
                    let json = JSON(response)
                    if json["meta"]["message"] == "OK" {
                        // Delete the cell
                        self.songViewModelController.deleteModel(section: indexPath.section, index: indexPath.row)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    } else {
                        let title = "Song Could Not Be Deleted"
                        let message = "This song is no longer in the queue"
                        showAlert(title: title, message: message)
                    }
                }
            }
        }
    }
    
    // Do not show delete option on swipe if the user is not the host and viewing the queue.
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if Globals.partyDeviceId == nil && tableView.isEditing {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        songViewModelController.moveModel(oldSection: sourceIndexPath.section,
                                          oldIndex: sourceIndexPath.row,
                                          newSection: destinationIndexPath.section,
                                          newIndex: destinationIndexPath.row)
        var newQueue = [String]()
        let oldQueue = songViewModelController.returnModels(section: sourceIndexPath.section)
        for song in oldQueue {
            newQueue.append(song.songURL)
        }
        if let partyID = UIDevice.current.identifierForVendor?.uuidString {
            Api.shared.reorderQueue(partyID: partyID, songs: newQueue) { (response) in
                let json = JSON(response)
                if json["meta"]["message"] == "OK" {
                    // Do nothing reorder successful
                } else {
                    // Should never happen!!!!
                    let title = "Rearranging Queue Failed"
                    let message = "The songs could not be rearranged"
                    showAlert(title: title, message: message)
                }
            }
        }
    }
    
    @IBAction func goHome(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "Home")
        dismiss(animated: true, completion: nil)
    }

}


