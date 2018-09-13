//
//  ChooseCampusVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/26/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class ChooseCampusVC: UITableViewController {
    
    var subscribedMovements = [String]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var campuses: Results<Campus>!
    private var filteredCampuses = [Campus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose Campus"
        self.configureTableView()
        self.configureSearchController()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
        
        self.subscribedMovements = LocalStorage.preferences.getObject(forKey: .subscribedMovements) as? [String] ?? []
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.campuses = DatabaseManager.instance.getCampuses()
        let _ = DatabaseManager.instance.getMovements()
    }
    
    private func configureSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Campuses"
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
    }
    
    private func configureTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerCell(CampusCell.self)
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        self.filteredCampuses = self.campuses.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        self.tableView.reloadData()
    }
    
    private func isFiltering() -> Bool {
        return self.searchController.isActive && !self.searchBarIsEmpty()
    }
    
    @objc private func doneButtonPressed() {
        self.finalizeSubsciption()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func campusAt(_ indexPath: IndexPath) -> Campus {
        if self.isFiltering() {
            return self.filteredCampuses[indexPath.row]
        } else {
            return self.campuses[indexPath.row]
        }
    }
}

extension ChooseCampusVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering() {
            return self.filteredCampuses.count
        }
        return self.campuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CampusCell.self, indexPath: indexPath)
        cell.configure(with: self.campusAt(indexPath), subscribedMovements: self.subscribedMovements)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let selectedCampus = self.campusAt(indexPath)
        cell?.isSelected = false
        
        if selectedCampus.movements.count > 1 {
            let vc = ChooseMovementVC()
            vc.campus = selectedCampus
            vc.movementSubscriptionDelegate = self
            self.show(vc, sender: self)
        } else {
            let selectedMovement = selectedCampus.movements[0]
            if self.isSubscribed(to: selectedMovement.id) {
                cell?.accessoryType = .none
                self.unsubscribe(from: selectedMovement.id)
            } else {
                cell?.accessoryType = .checkmark
                self.subscribe(to: selectedMovement.id)
            }
        }
    }
}

extension ChooseCampusVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        
        self.filterContentForSearchText(searchBarText)
    }
}

extension ChooseCampusVC: DatabaseListenerProtocol {
    func updatedCampuses() {
        print("Campuses were updated - refreshing UI")
        self.tableView.reloadData()
    }
    
    func updatedMovements() {
        print("Movements were updated - refreshing UI")
        self.tableView.reloadData()
    }
}

extension ChooseCampusVC: MovementSubscriptionDelegate {
    func isSubscribed(to movementId: String) -> Bool {
        return self.subscribedMovements.contains(movementId)
    }
    
    func subscribe(to movementId: String) {
        guard !self.isSubscribed(to: movementId) else {
            print("Already subscribed to movement: \(movementId)")
            return
        }
        
        self.subscribedMovements.append(movementId)
    }
    
    func unsubscribe(from movementId: String) {
        guard self.isSubscribed(to: movementId) else {
            print("Already unsubscribed from movement: \(movementId)")
            return
        }
        
        let existingMovementIndex = self.subscribedMovements.index(of: movementId)!
        self.subscribedMovements.remove(at: existingMovementIndex)
    }
    
    func finalizeSubsciption() {
        // Save id's of chosen movements in UserDefaults
        LocalStorage.preferences.set(self.subscribedMovements, forKey: .subscribedMovements)
        // TODO (Issue #186): Update data on backend if logged in
    }
}

protocol MovementSubscriptionDelegate {
    var subscribedMovements: [String] { get set }
    
    func isSubscribed(to movementId: String) -> Bool
    func subscribe(to movementId: String)
    func unsubscribe(from movementId: String)
    func finalizeSubsciption()
}
