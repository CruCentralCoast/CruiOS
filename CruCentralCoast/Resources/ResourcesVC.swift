//
//  ResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import WebKit
import RealmSwift

@IBDesignable
class ResourcesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var dataArray: Results<Resource>!
    
    private var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.dataArray = DatabaseManager.instance.getResources()
    }
    
    private func configureTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerCell(ResourceTableViewCell.self)
    }
}

extension ResourcesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ResourceTableViewCell.self, indexPath: indexPath)
        let resource = self.dataArray[indexPath.row]
        cell.authorLabel.text = resource.author
        cell.titleLabel.text = resource.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
}

extension ResourcesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        let resource = self.dataArray[indexPath.row]
        if let resourceURLString = resource.url {
            self.showWebView(from: resourceURLString, with: self.activityIndicator, navigationDelegate: self)
        }
    }
}

extension ResourcesVC: DatabaseListenerProtocol {
    func updatedResources() {
        print("Resources were updated - refreshing UI")
        self.tableView.reloadData()
    }
}

extension ResourcesVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
}
