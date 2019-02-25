//
//  SearchViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit

class SearchViewController: ViewController  {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            let keywords = text.replacingOccurrences(of: " ", with: "+")
            let searchURL = "https://api.spotify.com/v1/search?q=\(keywords)&type=track"
            self.view.endEditing(true)
            print(searchURL)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Clear the search results
            print("Empty text field")
        }
    }
}
