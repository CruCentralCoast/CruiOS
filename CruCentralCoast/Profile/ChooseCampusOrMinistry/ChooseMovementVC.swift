//
//  ChooseMovementVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 7/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ChooseMovementVC: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var tableView = UITableView()
    private var movements: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var filteredMovements: [String] = []
    
    init() {
        self.movements = ["Movement 1", "Movement 2", "Movement 3"]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureSearchController()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
    }
    
    private func configureSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Movements"
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
    }
    
    private func configureTableView() {
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ])
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerCell(CampusTableViewCell.self)
        self.navigationItem.searchController = UISearchController()
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredMovements = self.movements.filter({( objectTitle : String) -> Bool in
            return objectTitle.lowercased().contains(searchText.lowercased())
        })
        
        self.tableView.reloadData()
    }
    
    private func isFiltering() -> Bool {
        return self.searchController.isActive && !self.searchBarIsEmpty()
    }
    
    @objc private func doneButtonPressed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ChooseMovementVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredMovements.count
        }
        
        return self.movements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CampusTableViewCell.self, indexPath: indexPath)
        cell.titleLabel.text = self.isFiltering() ? self.filteredMovements[indexPath.row] : self.movements[indexPath.row]
        cell.accessoryType = .none
        return cell
    }
}

extension ChooseMovementVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = cell?.accessoryType == .checkmark ? .none : .checkmark
        cell?.isSelected = false
        
    }
}

extension ChooseMovementVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        self.filterContentForSearchText(searchBarText)
    }
}
