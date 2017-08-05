//
//  NotificationsViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NotificationsViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.estimatedRowHeight = 105.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //Set the empty set delegate and source
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        tableView.reloadData()
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        //Set the empty set delegate and source
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        tableView.reloadData()
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        
        if let savedNotifications = loadNotifications() {
            notifications += savedNotifications
        }
        else {
            // Load the sample data.
            // loadSampleNotifications()
        }
        
        //Temporary method to test out persisting data
        saveNotifications()
        
    }
    
    //Set the text to be displayed when the table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        self.tableView.separatorColor = UIColor.clear
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "You do not have any notifications!", attributes: attributes)
        
    }

    //Set the text to be displayed when the table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        self.tableView.separatorColor = UIColor.clear
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "You do not have any notifications!", attributes: attributes)
    }

    //Set the text to be displayed when the table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        self.tableView.separatorColor = UIColor.clear
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "You do not have any notifications!", attributes: attributes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("The current value of notifications.count is \(notifications.count)")
        return notifications.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
        
        let not = notifications[indexPath.row]

        // Configure the cell...
        cell.title.text = not.title
        cell.content.text = not.content
        cell.timeSince.text = not.dateReceived.offsetFrom(Date())
        
        
        
        return cell
    }
    
    // MARK: NSCoding
    func saveNotifications() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notifications, toFile: Notification.ArchiveURL.path)
        
        if !isSuccessfulSave {
            print("Failed to save notifications...")
        }
    }
    
    func loadNotifications() -> [Notification]? {
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: Notification.ArchiveURL.path) as? [Notification]

    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
