//
//  MissionsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 6/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class MissionsVC: UITableViewController {
    
    var dataArray: Results<Mission>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(MissionCell.self)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.dataArray = DatabaseManager.instance.getMissions()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(MissionCell.self, indexPath: indexPath)
        
        cell.configure(with: self.dataArray[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(MissionDetailsVC.self)
        vc.configure(with: self.dataArray[indexPath.row])
        self.present(vc, animated: true, completion: nil)
    }
}

extension MissionsVC: DatabaseListenerProtocol {
    func updatedMissions() {
        print("Missions were updated - refreshing UI")
        self.tableView.reloadData()
    }
}
