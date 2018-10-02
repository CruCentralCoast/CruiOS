//
//  EventsVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/1/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class EventsVC: UITableViewController {
    
    var dataArray: Results<Event>!
    
    private lazy var emptyTableViewLabel: UILabel = {
        let label = UILabel()
        label.text = "No Events"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(EventsTableCell.self)
        self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let currentDate = Date()
        let calendar = Calendar.current
        //offset by 1 to keep the event for one more day
        let dateOffset = calendar.date(byAdding: .day, value: -1, to: currentDate)
        
        let subscribedMovements = LocalStorage.preferences.getObject(forKey: .subscribedMovements) as? [String] ?? []
        self.dataArray = DatabaseManager.instance.getEvents()
            .filter("ANY movements.id IN %@", subscribedMovements)
            .filter("endDate >= %@", dateOffset)
            .sorted(byKeyPath: "startDate")
        
        self.tableView.reloadData()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(EventsTableCell.self, indexPath: indexPath)
        cell.event = self.dataArray[indexPath.item]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(EventDetailsVC.self) as EventDetailsVC
        vc.configure(with: self.dataArray[indexPath.item])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}

extension EventsVC: DatabaseListenerProtocol {
    func updatedEvents() {
        print("Events were updated - refreshing UI")
        self.tableView.reloadData()
    }
}
