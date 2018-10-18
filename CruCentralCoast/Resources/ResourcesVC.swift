//
//  ResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import WebKit
import RealmSwift

enum Scope: String {
    case all = "All"
    case audio = "Audio"
    case videos = "Videos"
    case articles = "Articles"
}

class ResourcesVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var resources: Results<Resource>!
    private var filteredResources = [Resource]()
    
    private var activityIndicator = UIActivityIndicatorView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureSearch()
        self.insertProfileButtonInNavBar()
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.resources = DatabaseManager.instance.getResources()
    }
    
    private func configureSearch() {
        // Setup the Search Controller
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
        // Setup the Scope Bar
        self.searchController.searchBar.scopeButtonTitles = [Scope.all.rawValue, Scope.audio.rawValue, Scope.videos.rawValue, Scope.articles.rawValue]
        self.searchController.searchBar.delegate = self
    }
    
    private func configureTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerCell(ResourceTableViewCell.self)
    }
    
    private func scopeStringFrom(_ resourceType: ResourceType) -> String {
        switch resourceType {
        case .article:
            return Scope.articles.rawValue
        case .video:
            return Scope.videos.rawValue
        case .audio:
            return Scope.audio.rawValue
        }
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredResources = self.resources.filter({( resource : Resource) -> Bool in
            let doesCategoryMatch = (scope == "All") || (self.scopeStringFrom(resource.type) == scope)
            
            if self.searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && resource.title.lowercased().contains(searchText.lowercased())
            }
        })
        self.tableView.reloadData()
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = self.searchController.searchBar.selectedScopeButtonIndex != 0
        return self.searchController.isActive && (!self.searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    private func resourceAt(_ indexPath: IndexPath) -> Resource {
        if self.isFiltering() {
            return self.filteredResources[indexPath.row]
        } else {
            return self.resources[indexPath.row]
        }
    }
}

extension ResourcesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ResourceTableViewCell.self, indexPath: indexPath)
        let resource = self.resourceAt(indexPath)
        
        var typeText: String = " | "
        switch resource.type {
        case .article:
            typeText += "Article"
        case .video:
            typeText += "Video"
        case .audio:
            typeText += "Audio"
        }
        
        cell.titleLabel.text = resource.title
        cell.authorLabel.text = resource.author + typeText
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredResources.count
        }
        return self.resources.count
    }
}

extension ResourcesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        let resource = self.resourceAt(indexPath)
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

extension ResourcesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let searchText = searchBar.text,
        let scopeButtonTitles = searchBar.scopeButtonTitles else {
            return
        }
        let scope = scopeButtonTitles[searchBar.selectedScopeButtonIndex]
        self.filterContentForSearchText(searchText, scope: scope)
    }
}

extension ResourcesVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard let searchText = searchBar.text,
            let scopeButtonTitles = searchBar.scopeButtonTitles else {
                return
        }
        self.filterContentForSearchText(searchText, scope: scopeButtonTitles[selectedScope])
    }
}
