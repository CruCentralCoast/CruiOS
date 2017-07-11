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
    var selectedGroup: CommunityGroup!

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
        
        //Add drop shadow
        cell.card.layer.shadowColor = UIColor.black.cgColor
        cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.card.layer.shadowOpacity = 0.25
        cell.card.layer.shadowRadius = 2
        
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
    
    //opens sign up form for community group
    
    @IBAction func joinGroup(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            let group = groups[(indexPath?.row)!]
            self.selectedGroup = group
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comGroupSignUp" {
            let vc = segue.destination as! SubmitInformationViewController
            vc.comGroup = self.selectedGroup
        }
    }
    

}
