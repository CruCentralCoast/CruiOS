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
    
}

class CommunityGroupsVC: UITableViewController {

    
    let days: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    
    var dataArray: Results<CommunityGroup>!
    var dataDictionary = [WeekDay : [CommunityGroup]]()
    
    var filteredArray: [CommunityGroup] = []
    var filteredDictionary = [WeekDay : [CommunityGroup]]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
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
        self.dataArray = DatabaseManager.instance.getCommunityGroups()
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section].rawValue.capitalized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = days[section]
        
        if isFiltering() {
            if let filteredGroups = self.filteredDictionary[day] {
                return filteredGroups.count
            }
        }
        else {
            if let communityGroups = self.dataDictionary[day] {
                return communityGroups.count
            }
            
            return 0
        }
        
        return 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CommunityGroupCell.self, indexPath: indexPath)
        
        if isFiltering() {
            if let filteredDay = self.filteredDictionary[days[indexPath.section]] {
                cell.configure(with: filteredDay[indexPath.row])
            }
        }
        else {
            if let day = self.dataDictionary[days[indexPath.section]] {
                cell.configure(with: day[indexPath.row])
            }
        }
         
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "CommunityGroups", bundle: nil).instantiateViewController(CommunityGroupDetailsVC.self)
        let day = self.dataDictionary[days[indexPath.section]]!
        vc.configure(with: day[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        
        filteredArray = dataArray.filter({ (communityGroup : CommunityGroup) -> Bool in
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
        tableView.reloadData()
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

