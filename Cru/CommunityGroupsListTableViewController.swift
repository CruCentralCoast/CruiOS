//
//  CommunityGroupsListTableViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/2/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class CommunityGroupsListTableViewController: UITableViewController {
    
    // MARK: - Properties
    var groups = [CommunityGroup]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Community Groups"
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        //MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        loadCommunityGroups()

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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let group = groups[indexPath.row]
        
        if group.imgURL == "" {
            return 194.0
        }
        else {
            return 340.0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! CommunityGroupTableViewCell
        
        cell.ministryLabel.text = groups[indexPath.row].parentMinistry
        cell.typeLabel.text = groups[indexPath.row].type
        cell.meetingTimeLabel.text = groups[indexPath.row].getMeetingTime()
        
        if groups[indexPath.row].imgURL != "" {
            cell.groupImage.load.request(with: groups[indexPath.row].imgURL)
        }
        else {
            cell.groupImage.isHidden = true
            cell.leaderTopConstraint.constant = 12
        }
        
        
        return cell
    }
    
    
    // MARK: - Helper Functions
    private func loadCommunityGroups() {
        
        //Make API call here later
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
    

    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
