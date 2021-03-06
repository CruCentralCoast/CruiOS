//
//  CommunityGroupsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class CommunityGroupHeader: UIView {
    // TODO: make header view with text describing what a community group is
}

class CommunityGroupsVC: UITableViewController {

    let days: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    var filteredDays: [WeekDay] = []
    
    var dataArray: Results<CommunityGroup>!
    var dataDictionary = [WeekDay : [CommunityGroup]]()
    
    var filteredArray: [CommunityGroup] = []
    var filteredDictionary = [WeekDay : [CommunityGroup]]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var emptyTableViewLabel: UILabel = {
        let label = UILabel()
        label.text = "No Community Groups"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        return label
    }()
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(CommunityGroupCell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        // Setup the Search Controller
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search for Groups"
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let subscribedMovements = LocalStorage.preferences.getObject(forKey: .subscribedMovements) as? [String] ?? []
        self.dataArray = DatabaseManager.instance.getCommunityGroups().filter("movement.id IN %@", subscribedMovements)
        self.dataDictionary = self.dataArray.toDictionary(with: { $0.weekDay })
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataArray.count == 0 {
            self.tableView.backgroundView = self.emptyTableViewLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
        }
        
        if isFiltering() {
            return self.filteredDays.count
        }
        
        return self.days.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering() {
            print("filtered days: ", self.filteredDays)
            return self.filteredDays[section].rawValue.capitalized
        }
        
        return self.days[section].rawValue.capitalized
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            let day = self.filteredDays[section]
            if let filteredGroups = self.filteredDictionary[day] {
                return filteredGroups.count
            }
        }
        
        else {
            let day = self.days[section]
            if let communityGroups = self.dataDictionary[day] {
                return communityGroups.count
            }
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CommunityGroupCell.self, indexPath: indexPath)
        if isFiltering() {
            // check if there's item(s) for that day
            if let filteredDay = self.filteredDictionary[self.filteredDays[indexPath.section]] {
                cell.configure(with: filteredDay[indexPath.row])
            }
        }
        
        else {
            // check if there's item(s) for that day
            if let day = self.dataDictionary[self.days[indexPath.section]] {
                cell.configure(with: day[indexPath.row])
            }
        }
         
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "CommunityGroups", bundle: nil).instantiateViewController(CommunityGroupDetailsVC.self)
        if isFiltering() {
            if let filteredDay = self.filteredDictionary[self.filteredDays[indexPath.section]] {
                vc.configure(with: filteredDay[indexPath.row])
            }
        }
        
        else {
            if let day = self.dataDictionary[self.days[indexPath.section]] {
                vc.configure(with: day[indexPath.row])
            }
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private instance methods
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        self.filteredDays.removeAll()
        self.filteredArray = self.dataArray.filter({ (communityGroup : CommunityGroup) -> Bool in
            
            // specified search criteria to filter
            let searchArray = [communityGroup.gender.rawValue,
                               communityGroup.leaderNames,
                               communityGroup.time,
                               communityGroup.weekDay.rawValue,
                               communityGroup.year.rawValue]
            for category in searchArray {
                if category?.lowercased().contains(searchText.lowercased()) ?? false {
                    return true
                }
            }
            return false
        })
        
        self.filteredDictionary = self.filteredArray.toDictionary { $0.weekDay }
        self.filteredDays = self.days.filter({ self.filteredDictionary[$0] != nil })
        self.tableView.reloadData()
    }
}

extension CommunityGroupsVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension CommunityGroupsVC: DatabaseListenerProtocol {
    func updatedCommunityGroups() {
        print("Community Groups were updated - refreshing UI")
        self.dataDictionary = self.dataArray.toDictionary { $0.weekDay }
        self.tableView.reloadData()
    }
}

// extension for Results from Firebase
extension Results {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:[Element]] {
        var dict = [Key:[Element]]()
        for elements in self {
            if (dict[selectKey(elements)] != nil) {
                dict[selectKey(elements)]?.append(elements)
            }
            else {
                dict[selectKey(elements)] = [elements]
            }
        }
        return dict
    }
}

// extensions for items in array to be filtered for searching
extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:[Element]] {
        var dict = [Key:[Element]]()
        for elements in self {
            if (dict[selectKey(elements)] != nil) {
                dict[selectKey(elements)]?.append(elements)
            }
            else {
                dict[selectKey(elements)] = [elements]
            }
            
        }
        return dict
    }
}
