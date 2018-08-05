//
//  ResourcesTableViewCollectionViewCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/3/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class ResourcesTableViewCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var resources: Results<Resource>!
    var filteredResources: [Resource]!
    var resourcePresentingDelegate: ResourcePresentingDelegate?
    var type: ResourceType = .audio {
        didSet {
            self.activityIndicator.startAnimating()
            self.tableView.isHidden = true
            self.filteredResources = self.resources.filter { $0.type == self.type }
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            self.tableView.isHidden = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerCell(AudioResourcesCell.self)
        self.tableView.registerCell(VideosResourcesCell.self)
        self.tableView.registerCell(ArticlesResourcesCell.self)
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(self.refreshResources(_:)), for: .valueChanged)
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.resources = DatabaseManager.instance.getResources()
    }
    
    @objc private func refreshResources(_ refreshControl: UIRefreshControl) {
        self.filteredResources = self.resources.filter { $0.type == self.type }
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}

extension ResourcesTableViewCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredResources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let resource = self.filteredResources[indexPath.row]
        switch self.type {
        case .audio:
            let cell = tableView.dequeueCell(AudioResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = resource.title
            cell.dateLabel.text = resource.formattedDate
            return cell
        case .video:
            let cell = tableView.dequeueCell(VideosResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = resource.title
            cell.dateLabel.text = resource.formattedDate
            if let imageLink = resource.imageLink {
                if let url = URL(string: imageLink) {
                    cell.previewImage.downloadedFrom(url: url)
                } else {
                    cell.imageWidthConstraint.constant = 0
                }
            }
            return cell
        case .article:
            let cell = tableView.dequeueCell(ArticlesResourcesCell.self, indexPath: indexPath)
            cell.titleLabel.text = resource.title
            cell.dateLabel.text = resource.formattedDate
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        let resource = self.filteredResources[indexPath.row]
        self.resourcePresentingDelegate?.presentResource(of: self.type, resource: resource)
    }
}

extension ResourcesTableViewCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

extension ResourcesTableViewCollectionViewCell: DatabaseListenerProtocol {
    func updatedResources() {
        print("Resources were updated - refreshing UI")
        self.refreshResources(self.tableView.refreshControl!)
    }
}
