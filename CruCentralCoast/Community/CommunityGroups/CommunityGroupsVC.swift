//
//  CommunityGroupsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class CommunityGroupsVC: UITableViewController {

    
    let days: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    var dataArray: Results<CommunityGroup>!
    var dataDictionary = [WeekDay : [CommunityGroup]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(CommunityGroupCell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.dataArray = DatabaseManager.instance.getCommunityGroups()
        
        self.dataDictionary = self.dataArray.toDictionary { $0.weekDay }
        print("KEYS:")
        print(self.dataDictionary.keys)
        print()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return days[section].rawValue.capitalized
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return days.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let day = days[section]
        if let communityGroups = self.dataDictionary[day] {
            return communityGroups.count
        }
        else {
            return 0
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CommunityGroupCell.self, indexPath: indexPath)
        
        if let day = self.dataDictionary[days[indexPath.section]] {
            cell.configure(with: day[indexPath.row])
        }
         
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "CommunityGroups", bundle: nil).instantiateViewController(CommunityGroupDetailsVC.self)
        let day = self.dataDictionary[days[indexPath.section]]!
        vc.configure(with: day[indexPath.row])
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension CommunityGroupsVC: DatabaseListenerProtocol {
    func updatedCommunityGroups() {
        print("Community Groups were updated - refreshing UI")
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
