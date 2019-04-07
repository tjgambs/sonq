//
//  SearchViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchViewController: ViewController  {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTable: UITableView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var searchResultsLabel: UILabel!

    var accessToken: String?
    var refreshTokenTimer: Timer!
    
    fileprivate var searchResults:[SongModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshToken()
        refreshTokenTimer = Timer.scheduledTimer(
            timeInterval: 1800,
            target: self,
            selector: #selector(self.refreshToken),
            userInfo: nil,
            repeats: true)
        self.searchBar.delegate = self
        self.searchResultTable.delegate = self
        self.searchResultTable.dataSource = self
        self.searchResultTable.keyboardDismissMode = .onDrag
    }

    @objc func refreshToken() -> Void {
        Spotify.getAuthToken()
            .done { value -> Void in
                let json = JSON(value)
                self.accessToken = json.dictionary!["access_token"]?.stringValue
            }
            .catch { error in
                print(error.localizedDescription)
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let token = self.accessToken {
            if let text = searchBar.text {
                let keywords = text.replacingOccurrences(of: " ", with: "+")
                let searchURL = "https://api.spotify.com/v1/search?q=\(keywords)&type=track"
                Spotify.getSearchResults(searchURL: searchURL, accessToken: token)
                    .done { value -> Void in
                        let json = JSON(value)
                        let items = json["tracks"]["items"].arrayValue
                        if items.count == 0 {
                            self.searchResults = []
                            self.resultsLabel.text = "Results"
                            return self.showAlert(
                                title:"No search results found",
                                message:"Please try another search keyword.")
                        }
                        self.searchResults = items.map{ SongModel(json: $0, addedBy: "Tim") }
                        self.view.endEditing(true)
                        self.searchResultTable.reloadData()
                        self.resultsLabel.text = "Results"
                        self.searchResultsLabel.text = ""
                    }
                    .catch { error in
                        print(error.localizedDescription)
                }
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchResults = []
            self.searchResultTable.reloadData()
            self.resultsLabel.text = ""
            self.searchResultsLabel.text = "Search results will appear here."
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultPrototype", for: indexPath) as! SongCellModel
        let viewModel = self.searchResults[indexPath.row]
        cell.configure(viewModel)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 14.0/255, green: 15.0/255, blue: 38.0/255, alpha: 0.33)
        cell.selectedBackgroundView = backgroundView
        // TODO: Put a check next to the cells containing this users queued songs. Clear the addedBy name to be blank for these songs and disable them.
        // cell.accessoryType = .checkmark
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedSong = self.searchResults[indexPath.row]
        // TODO: Check and make sure this song isn't in the queue, then add it.
        print(selectedSong)
        
        MediaPlayer.shared.play(song: selectedSong)
    }
    
}
