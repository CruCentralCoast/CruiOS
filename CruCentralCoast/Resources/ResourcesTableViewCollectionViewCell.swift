//
//  ResourcesTableViewCollectionViewCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/3/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ResourcesTableViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tableView: UITableView!
    
    var resources: [Resource] = []
    var resourcePresentingDelegate: ResourcePresentingDelegate?
    var type: ResourceType = .audio {
        didSet {
            DatabaseManager.instance.getResources(ofType: self.type) {resources in
                self.resources = resources
                self.tableView.reloadData()
            }
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
        return self.resources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = self.resources[indexPath.row]
        switch self.type {
        case .audio:
            let cell = tableView.dequeueCell(AudioResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = resource.title
            cell.dateLabel.text = resource.date.description
            return cell
        case .video:
            let cell = tableView.dequeueCell(VideosResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = resource.title
            cell.dateLabel.text = resource.date.description
            if let videoResource = resource as? VideoResource {
                if let url = URL(string: videoResource.imageURL) {
                    cell.imageView?.downloadedFrom(url: url)
                } else {
                    cell.imageView?.image = #imageLiteral(resourceName: "second")
                }
            }
            return cell
        case .article:
            let cell = tableView.dequeueCell(ArticlesResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = resource.title
            cell.dateLabel.text = resource.date.description
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        let resource = self.resources[indexPath.row]
        self.resourcePresentingDelegate?.presentResource(of: self.type, resource: resource)
    }
}

extension ResourcesTableViewCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.type {
        case .audio:
            return 53
        case .video:
            return 53
        case .article:
            return 53
        }
    }
}
