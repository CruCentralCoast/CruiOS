//
//  ResourcesTableViewCollectionViewCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/3/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

enum ResourcesTableViewType {
    case audio
    case videos
    case articles
}

class ResourcesTableViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tableView: UITableView!
    
    var type: ResourcesTableViewType = .audio {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerCell(AudioResourcesCell.self)
        self.tableView.registerCell(VideosResourcesCell.self)
        self.tableView.registerCell(ArticlesResourcesCell.self)
    }
}

extension ResourcesTableViewCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.type {
        case .audio:
            return 20
        case .videos:
            return 20
        case .articles:
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.type {
        case .audio:
            let cell = tableView.dequeueCell(AudioResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = "Audio " + String(indexPath.row)
            cell.dateLabel.text = "Mar 17, 2018"
            return cell
        case .videos:
            let cell = tableView.dequeueCell(VideosResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = "Video " + String(indexPath.row)
            cell.dateLabel.text = "Mar 17, 2018"
            return cell
        case .articles:
            let cell = tableView.dequeueCell(ArticlesResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = "Article " + String(indexPath.row)
            cell.dateLabel.text = "Mar 17, 2018"
            return cell
        }
    }
    
    //  Credit to https://stackoverflow.com/questions/40667985/how-to-hide-the-navigation-bar-and-toolbar-as-scroll-down-swift-like-mybridge
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // possibly put code here to switch between  large and small nav bar
    }
}

extension ResourcesTableViewCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.type {
        case .audio:
            return 68
        case .videos:
            return 53
        case .articles:
            return 66
        }
    }
}
