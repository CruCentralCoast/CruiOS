//
//  NotificationsVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class NotificationsVC: UITableViewController {
    
    var notifications = [String]()
    
    private lazy var emptyTableViewLabel: UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notifications"
        self.configureTableView()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
    }
    
    private func configureTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerClass(UITableViewCell.self)
    }
    
    @objc private func doneButtonPressed() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension NotificationsVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.notifications.count == 0 {
            self.tableView.backgroundView = self.emptyTableViewLabel
            return 0
        } else {
            self.tableView.backgroundView = nil
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(UITableViewCell.self, indexPath: indexPath)
        cell.textLabel?.text = self.notifications[indexPath.row]
        return cell
    }
}
