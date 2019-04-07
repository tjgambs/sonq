//
//  QueueViewController.swift
//  sonq
//
//  Created by Tim Gamble on 2/24/19.
//  Copyright © 2019 sonq. All rights reserved.
//

import UIKit
import SwiftyJSON

class QueueViewController: ViewController {
    
    @IBOutlet weak var emptyText: UILabel!
    @IBOutlet weak var queueResultTable: UITableView!
    private let refreshControl = UIRefreshControl()
    
    fileprivate var queueResults: [SongModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLabel()
        self.queueResultTable.delegate = self
        self.queueResultTable.dataSource = self
        
        if #available(iOS 10.0, *) {
            queueResultTable.refreshControl = refreshControl
        } else {
            queueResultTable.addSubview(refreshControl)
        }
        refreshControl.addTarget(
            self,
            action: #selector(refreshQueue),
            for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.refreshQueue()
    }
    
    @objc func refreshQueue() {
        // TODO: Go fetch the queue from the API and populate it into the searchResults
        
        self.queueResultTable.reloadData()
        self.updateLabel()
        self.refreshControl.endRefreshing()
    }
    
    func updateLabel() {
        if (queueResults.count == 0) {
            emptyText.text = "The queue is empty. Search for songs to add to the queue."
        } else {
            emptyText.text = ""
        }
    }

}

extension QueueViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.queueResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queueResultPrototype", for: indexPath) as! SongCellModel
        let viewModel = self.queueResults[indexPath.row]
        cell.configure(viewModel)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 14.0/255, green: 15.0/255, blue: 38.0/255, alpha: 0.33)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }    
}

