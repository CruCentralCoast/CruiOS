//
//  MinistryTeamsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/30/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class MinistryTeamsVC: UITableViewController {
    
    var dataArray: Results<MinistryTeam>!
    
    private lazy var emptyTableViewLabel: UILabel = {
        let label = UILabel()
        label.text = "No Ministry Teams"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(MinistryTeamCell.self)

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.dataArray = DatabaseManager.instance.getMinistryTeams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let subscribedMovements = LocalStorage.preferences.getObject(forKey: .subscribedMovements) as? [String] ?? []
        self.dataArray = DatabaseManager.instance.getMinistryTeams().filter("movement.id IN %@", subscribedMovements)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.dataArray.count == 0 {
            self.tableView.backgroundView = self.emptyTableViewLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(MinistryTeamCell.self, indexPath: indexPath)

        cell.configure(with: self.dataArray[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "MinistryTeams", bundle: nil).instantiateViewController(MinistryTeamDetailsVC.self)
        vc.configure(with: self.dataArray[indexPath.row])
        self.present(vc, animated: true, completion: nil)
    }
}

extension MinistryTeamsVC: DatabaseListenerProtocol {
    func updatedMinistryTeams() {
        print("Ministry Teams were updated - refreshing UI")
        self.tableView.reloadData()
    }
}
