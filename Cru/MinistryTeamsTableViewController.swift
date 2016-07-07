//
//  MinistryTeamsTableViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 5/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamsTableViewController: UITableViewController {

    var ministryTeamsStorageManager: MapLocalStorageManager!
    var ministryTeams = [MinistryTeam]()
    var ministries = [Ministry]()
    var signedUpMinistryTeams = [NSDictionary]()
    var selectedMinistryTeam: MinistryTeam!
    private let reuseIdentifierPic = "ministryTeamCell"
    private let reuseIdentifierNoPic = "ministryTeamNoPicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //setup local storage manager
        ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        self.ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        if !self.ministries.isEmpty {
            let ministryIds = ministries.map{$0.id}
            let params: [String:AnyObject] = ["parentMinistry":["$in":ministryIds]]
            
            //load ministry teams
            CruClients.getServerClient().getData(.MinistryTeam, insert: insertMinistryTeam, completionHandler: finishInserting, params: params)
        }
        else {
            print("NO MINISTRIES!!!")
        }
    }
    
    //inserts individual ministry teams into the table view
    private func insertMinistryTeam(dict : NSDictionary) {
        let addMinistryTeam = MinistryTeam(dict: dict)!
        
        if ministryTeamsStorageManager.getElement(addMinistryTeam.id) == nil {
            self.ministryTeams.insert(addMinistryTeam, atIndex: 0)
        }
    }
    
    //reload the collection view data and store whether or not the user is in the repsective ministries
    private func finishInserting(success: Bool) {
        //TODO: handle failure
        self.tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministryTeams.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let ministryTeam = ministryTeams[indexPath.row]
        let ministry = ministries.filter{$0.id == ministryTeam.parentMinistry}.first
        
        if ministryTeam.imageUrl == "" {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierNoPic, forIndexPath: indexPath) as! MinistryTeamNoPictureTableViewCell
            cell.ministryTeam = ministryTeam
            
            if ministry != nil {
                cell.ministryNameLabel.text = ministry!.name
            }
            else {
                cell.ministryNameLabel.text = "N/A"
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.signupButton.layer.setValue(indexPath.row, forKey: "index")
            
            //Add drop shadow
            cell.card.layer.shadowColor = UIColor.blackColor().CGColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifierPic, forIndexPath: indexPath) as! MinistryTeamsTableViewCell
            cell.ministryTeam = ministryTeam
            
            if ministry != nil {
                cell.ministryNameLabel.text = ministry!.name
            }
            else {
                cell.ministryNameLabel.text = "N/A"
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.signupButton.layer.setValue(indexPath.row, forKey: "index")
            
            //Add drop shadow
            cell.card.layer.shadowColor = UIColor.blackColor().CGColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            return cell
        }
    }
    
    //opens sign up form for ministry teams
    @IBAction func joinMinistryTeam(sender: UIButton) {
        let index = sender.layer.valueForKey("index") as! Int
        let ministry = ministryTeams[index]
        
        self.selectedMinistryTeam = ministry
        self.performSegueWithIdentifier("ministryTeamSignUp", sender: self)
    }
    
    //sets up segues with necessary data
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //set the ministry team of the sign up controller to the selected ministry team
        if segue.identifier == "ministryTeamSignUp" {
            let vc = segue.destinationViewController as! MinistryTeamSignUpViewController
            vc.ministryTeam = self.selectedMinistryTeam
        }
    }

}
