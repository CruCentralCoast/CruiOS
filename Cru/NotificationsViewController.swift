//
//  NotificationsViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NotificationsViewController: UITableViewController {
    
    var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure tableView
        self.tableView.estimatedRowHeight = 105.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.reloadData()

        // Configure refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "")
        self.refreshControl!.addTarget(self, action: #selector(self.downloadNotifications), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(self.refreshControl!)
        
        // Configure nav bar
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        // Download notifications
        self.downloadNotifications()
    }
    
    @objc fileprivate func downloadNotifications() {
        CruClients.getServerClient().getData(.Notification, insert: self.insertNotification(_:), completionHandler: self.finishNotifications(_:))
    }
    
    fileprivate func insertNotification(_ dict: NSDictionary) {
        if let notification = Notification(dict as? [String: AnyObject]) {
            self.notifications.append(notification)
        }
    }
    
    fileprivate func finishNotifications(_ success: Bool) {
        // Stop animating the refresh control
        if self.refreshControl?.isRefreshing == true {
            self.refreshControl?.endRefreshing()
        }
        
        // Add the notifications saved on the phone
        let savedNotifications = NotificationManager.shared.getSavedNotifications()
        for notification in savedNotifications {
            if !self.notifications.contains(notification) {
                self.notifications.append(notification)
            }
        }
        
        // Sort the notifications by date and reload the tableView
        self.notifications.sort { $0.0.dateReceived > $0.1.dateReceived }
        self.tableView.reloadData()
    }

    // MARK: Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        let not = notifications[indexPath.row]

        cell.title.text = not.title
        cell.content.text = not.content
        cell.timeSince.text = not.dateReceived.offsetFrom(Date())
        
        return cell
    }
}

// MARK: - DZNEmptyDataSet
extension NotificationsViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        self.tableView.separatorColor = UIColor.clear
        let attributes = [NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "You do not have any notifications!", attributes: attributes)
    }
}
