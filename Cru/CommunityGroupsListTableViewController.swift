//
//  CommunityGroupsListTableViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/2/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress
import DZNEmptyDataSet

class CommunityGroupsListTableViewController: UITableViewController, DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    // MARK: - Properties
    var groups = [CommunityGroup]()
    var hasConnection = true
    var answers = [[String:String]]()
    var ministries = [Ministry]()
    var ministryTable = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Community Groups"
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        //Set the cells for automatic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        
        //Load ministries
        createMinistryDictionary()
        
        //Check for connection then load events in the completion function
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        //loadCommunityGroups()

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
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let group = groups[indexPath.row]
        
        if group.imgURL == "" {
            //return 194.0
            return 194
        }
        else {
            return 340.0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! CommunityGroupTableViewCell
        
        if let parentMin = ministryTable[groups[indexPath.row].parentMinistry] {
            cell.ministryLabel.text = parentMin
        }
        else {
            cell.ministryLabel.text = "Unknown"
        }
        
        cell.typeLabel.text = groups[indexPath.row].type
        cell.meetingTimeLabel.text = groups[indexPath.row].getMeetingTime()
        
        cell.leaderLabel.text = groups[indexPath.row].getLeaderString()
        //print(groups[indexPath.row].getLeaderString())
        
        if groups[indexPath.row].imgURL != "" {
            cell.groupImage.load.request(with: groups[indexPath.row].imgURL)
        }
        else {
            cell.groupImage.isHidden = true
            cell.leaderTopConstraint.constant = 12
        }
        
        
        cell.sizeToFit()
        
        cell.setSignupCallback(jumpBackToGetInvolved)
        return cell
    }
    
    
    // MARK: - Helper Functions
    //Test to make sure there is a connection then load groups
    func finishConnectionCheck(_ connected: Bool){
        self.tableView!.emptyDataSetSource = self
        self.tableView!.emptyDataSetDelegate = self
        
        if(!connected){
            hasConnection = false
            //Display a message if either of the tables are empty
            
            self.tableView!.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            //hasConnection = false
        }else{
            hasConnection = true
            //API call to load groups
            CruClients.getCommunityGroupUtils().loadGroups(insertGroup, completionHandler: finishInserting)
            
            
        }
        
    }
    
    //Get ministry list from local storage
    //Create a dictionary with ministry id & name for easy lookup
    fileprivate func createMinistryDictionary() {
        ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        for ministry in ministries {
            ministryTable[ministry.id] = ministry.name
        }
    }
    
    //helper function for inserting group data
    //func loadGroups(_ inserter: @escaping (NSDictionary)->Void, completionHandler: @escaping (Bool)->Void) {
        
    fileprivate func insertGroup(_ dict: NSDictionary) {
        let group = CommunityGroup(dict: dict)
        
        //Have to do this so we can get the names of the leaders from the database
        DispatchQueue.global(qos: .userInitiated).async { // 1
            group.getLeaderNames()
            DispatchQueue.main.async { // 2
                self.tableView.reloadData()
            }
        }
        
        self.groups.insert(group, at: 0)
        
        
    }

    
    //helper function for finishing off inserting group data
    fileprivate func finishInserting(_ success: Bool) {
        //self.events.sort(by: {$0.startNSDate.compare($1.startNSDate as Date) == .orderedAscending})
        
       //Dismiss overlay here
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        self.tableView!.reloadData()
        
    }
    
    //Function to take user back to get involved once they've selected a group
    func jumpBackToGetInvolved() {
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKind(of: GetInvolvedViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    
    
    //Load Community groups
    private func loadCommunityGroups() {
        
        
        
        //load sample data for now
        
        var leader1 = [String: Any]()
        leader1[CommunityGroupLeaderKeys.name] = [CommunityGroupLeaderKeys.firstName: "Erica", CommunityGroupLeaderKeys.lastName: "Solum"]
        leader1[CommunityGroupLeaderKeys.phone] = "123-456-7890"
        leader1[CommunityGroupLeaderKeys.email] = "test@test.test"
        
        var leader2 = [String: Any]()
        leader2[CommunityGroupLeaderKeys.name] = [CommunityGroupLeaderKeys.firstName: "Test", CommunityGroupLeaderKeys.lastName: "Testerson"]
        leader2[CommunityGroupLeaderKeys.phone] = "123-456-7890"
        leader2[CommunityGroupLeaderKeys.email] = "test@test.test"

        
        let dict1 : NSDictionary = [
            CommunityGroupKeys.id : "9999",
            CommunityGroupKeys.name : "Erica's Test Community Group",
            CommunityGroupKeys.description : "This is a test group.",
            CommunityGroupKeys.type : "Senior",
            CommunityGroupKeys.ministry : "Cru Cal Poly",
            CommunityGroupKeys.meetingTime : "10:30 AM",
            CommunityGroupKeys.dayOfWeek : "Saturday",
            CommunityGroupKeys.leaders : [leader1, leader2],
            CommunityGroupKeys.imageURL : "https://s3-us-west-1.amazonaws.com/static.crucentralcoast.com/images/ministry-teams/evangelism-team-image.jpg"
        ]
        
        let dict2 : NSDictionary = [
            CommunityGroupKeys.id : "9998",
            CommunityGroupKeys.name : "A Test Community Group",
            CommunityGroupKeys.description : "This is the second test group.",
            CommunityGroupKeys.type : "Sophomore",
            CommunityGroupKeys.ministry : "Faculty Commons",
            CommunityGroupKeys.meetingTime : "2:00 PM",
            CommunityGroupKeys.dayOfWeek : "Monday",
            CommunityGroupKeys.leaders : [leader1, leader2],
            CommunityGroupKeys.imageURL : "https://s3-us-west-1.amazonaws.com/static.crucentralcoast.com/images/ministry-teams/community-team-image.jpg"
        ]
        
        let dict3 : NSDictionary = [
            CommunityGroupKeys.id : "9997",
            CommunityGroupKeys.name : "Another Test Community Group",
            CommunityGroupKeys.description : "This is the third test group.",
            CommunityGroupKeys.type : "Freshmen",
            CommunityGroupKeys.ministry : "Cru at Allan Hancock",
            CommunityGroupKeys.meetingTime : "11:00 AM",
            CommunityGroupKeys.dayOfWeek : "Sunday",
            CommunityGroupKeys.leaders : [leader1, leader2],
            CommunityGroupKeys.imageURL : "https://s3-us-west-1.amazonaws.com/static.crucentralcoast.com/images/ministry-teams/outreach-team-image.jpg"
        ]
        
        let dict4 : NSDictionary = [
            CommunityGroupKeys.id : "9996",
            CommunityGroupKeys.name : "The Last Test Community Group",
            CommunityGroupKeys.description : "This is the fourth test group.",
            CommunityGroupKeys.type : "Seniors",
            CommunityGroupKeys.ministry : "Fellowship of Christian Athletes in Action",
            CommunityGroupKeys.meetingTime : "11:00 AM",
            CommunityGroupKeys.dayOfWeek : "Sunday",
            CommunityGroupKeys.leaders : [leader1, leader2],
            CommunityGroupKeys.imageURL : ""
        ]
        
        let group1 = CommunityGroup(dict: dict1)
        let group2 = CommunityGroup(dict: dict2)
        let group3 = CommunityGroup(dict: dict3)
        let group4 = CommunityGroup(dict: dict4)
        
        groups.append(group1)
        groups.append(group2)
        groups.append(group3)
        groups.append(group4)
        
        
        
        
    }
    
    // MARK: Empty Data Set Functions
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if hasConnection == false {
            return UIImage(named: Config.noConnectionImageName)
        }
        else {
            return UIImage(named: Config.noEventsImage)
            
        }
        
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
    }
    

    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
