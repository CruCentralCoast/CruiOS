//
//  AudioResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class AudioResourcesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.rowHeight = 80;
        self.tableView.registerCell(AudioResourcesTableViewCell.self)
    }
    
}

extension AudioResourcesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(AudioResourcesTableViewCell.self, indexPath: indexPath)
        cell.titleLabel.text = "Audio Title " + String(indexPath.row)
        cell.dateLabel.text = "Mar 17, 2018"
        return cell
    }
}
