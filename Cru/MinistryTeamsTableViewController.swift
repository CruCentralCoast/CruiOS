//
//  MinistryTeamsTableViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 5/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MinistryTeamsTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    var ministryTeamsStorageManager: MapLocalStorageManager!
    var ministryTeams = [MinistryTeam]()
    var ministries = [Ministry]()
    var signedUpMinistryTeams = [NSDictionary]()
    var selectedMinistryTeam: MinistryTeam!
    var campusImage: UIImage!
    fileprivate let reuseIdentifierPic = "ministryTeamCell"
    fileprivate let reuseIdentifierNoPic = "ministryTeamNoPicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //setup local storage manager
        ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        self.ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        if !self.ministries.isEmpty {
            let ministryIds = ministries.map{$0.id}
            let params: [String:Any] = ["parentMinistry":["$in":ministryIds]]
            
            //load ministry teams
            CruClients.getServerClient().getData(.MinistryTeam, insert: insertMinistryTeam, completionHandler: finishInserting, params: params)
        }
        else {
            print("NO MINISTRIES!!!")
        }
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        campusImage = UIImage(named: Config.campusImage)!
    }
    
    //Set the text to be displayed when the table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "You are not subscribed to any campuses! Subscribe to a campus to join one of its ministry teams.", attributes: attributes)
        
    }
    
    //Set the spacer
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 30.0
    }
    
    //Set the image displayed when the table is empty
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return campusImage
    }
    
    //Set the background color to gray
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    //inserts individual ministry teams into the table view
    fileprivate func insertMinistryTeam(_ dict : NSDictionary) {
        let addMinistryTeam = MinistryTeam(dict: dict)!
        
        if ministryTeamsStorageManager.getElement(addMinistryTeam.id) == nil {
            self.ministryTeams.insert(addMinistryTeam, at: 0)
        }
    }
    
    //reload the collection view data and store whether or not the user is in the repsective ministries
    fileprivate func finishInserting(_ success: Bool) {
        //TODO: handle failure
        
        for minTeam in ministryTeams {
            minTeam.parentMinName = ministries.filter{$0.id == minTeam.parentMinistry}.first!.name
        }
        
        ministryTeams.sort()
        
        self.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministryTeams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ministryTeam = ministryTeams[indexPath.row]
        let ministry = ministries.filter{$0.id == ministryTeam.parentMinistry}.first
        
        if ministryTeam.imageUrl == "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierNoPic, for: indexPath) as! MinistryTeamNoPictureTableViewCell
            cell.ministryTeam = ministryTeam
            
            if ministry != nil {
                cell.ministryNameLabel.text = ministry!.name
            }
            else {
                cell.ministryNameLabel.text = "N/A"
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.signupButton.layer.setValue(indexPath.row, forKey: "index")
            
            //Add drop shadow
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierPic, for: indexPath) as! MinistryTeamsTableViewCell
            cell.ministryTeam = ministryTeam
            
            if ministry != nil {
                cell.ministryNameLabel.text = ministry!.name
            }
            else {
                cell.ministryNameLabel.text = "N/A"
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.signupButton.layer.setValue(indexPath.row, forKey: "index")
            
            //Add drop shadow
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            return cell
        }
    }
    
    //opens sign up form for ministry teams
    @IBAction func joinMinistryTeam(_ sender: UIButton) {
        let index = sender.layer.value(forKey: "index") as! Int
        let ministry = ministryTeams[index]
        
        self.selectedMinistryTeam = ministry
        self.performSegue(withIdentifier: "ministryTeamSignUp", sender: self)
    }
    
    //sets up segues with necessary data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //set the ministry team of the sign up controller to the selected ministry team
        if segue.identifier == "ministryTeamSignUp" {
            let vc = segue.destination as! MinistryTeamSignUpViewController
            vc.ministryTeam = self.selectedMinistryTeam
        }
    }

}
