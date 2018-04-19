//
//  AudioResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class AudioResources: NSObject {
    
}

extension AudioResources: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(AudioResourcesCell.self, indexPath: indexPath)
        cell.titleLabel.text = "Audio Title " + String(indexPath.row)
        cell.dateLabel.text = "Mar 17, 2018"
        return cell
    }
}

