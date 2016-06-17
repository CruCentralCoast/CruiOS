//
//  MinistryTeamViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 4/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //view objects for hiding and showing the table view
    @IBOutlet weak var ministryTeamView: UIView!
    @IBOutlet weak var ministryTeamTableView: UITableView!
    @IBOutlet weak var joinMTeamView: UIView!
    
    //vars for holding ministry team data and the local storage manager
    var ministryTeams = [NSDictionary]()
    var ministryTeamsStorageManager: MapLocalStorageManager!
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //populate view and show correct view
        populateJoinedMinistryTeams()
        showCorrectMinistryTeamsView()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.ministryTeamTableView.addSubview(self.refreshControl)
    }
    
    //if the view did appear refresh it
    override func viewWillAppear(animated: Bool) {
        refresh(self)
    }
    
    //function for refreshing the ministry team list
    func refresh(sender: AnyObject) {
        self.ministryTeams.removeAll()
        populateJoinedMinistryTeams()
        showCorrectMinistryTeamsView()
        endRefreshing()
    }
    
    //completion handler for finishing refreshing
    func endRefreshing() {
        if let refresh = self.refreshControl {
            self.ministryTeamTableView.reloadData()
            refresh.endRefreshing()
        }
    }
    
    //retrieves all ministry teams that the user has signed up for
    func populateJoinedMinistryTeams() {
        self.ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        let joinedTeamIds = ministryTeamsStorageManager.getKeys()

        for id in joinedTeamIds {
            var ministryTeam: Dictionary<String, String>! = [:]
            
            ministryTeam["id"] = id
            ministryTeam["name"] = (ministryTeamsStorageManager.getElement(id) as! String)
            self.ministryTeams.append(ministryTeam)
        }
    }
    
    //shows the table view or the "join" view depending on how many teams
    //the user has joined
    func showCorrectMinistryTeamsView(){
        if self.ministryTeams.count > 0 {
            hideMinistryTableView(false)
        }
        else {
            hideMinistryTableView(true)
        }
    }
    
    //toggle table view
    private func hideMinistryTableView(isHidden: Bool) {
        if isHidden {
            joinMTeamView.hidden = false
            ministryTeamView.hidden = true
        }
        else {
            ministryTeamView.hidden = false
            joinMTeamView.hidden = true
        }
    }
    
    //navigates to the ministry teams list
    @IBAction func onTouchSeeMore(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "ministryteam", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("MinistryTeamsCollectionViewController")
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    /* Table View Delegate code */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministryTeams.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // your cell coding
        let cell = tableView.dequeueReusableCellWithIdentifier("ministryTeam") as! JoinedTeamsTableViewCell
        let ministryTeam = ministryTeams[indexPath.item]
        cell.ministryTeam = ministryTeam
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ministryTeam = ministryTeams[indexPath.item]
        
        let viewController = self.storyboard!.instantiateViewControllerWithIdentifier("MinistryTeamDetailViewController") as! MinistryTeamDetailViewController
        viewController.ministryTeamDict = ministryTeam
        viewController.listVC = self
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func unwindToMinistryTeamsList(segue: UIStoryboardSegue) {
        refresh(self)
    }
}
