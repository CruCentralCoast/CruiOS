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
        self.refreshControl.addTarget(self, action: #selector(MinistryTeamViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.ministryTeamTableView.addSubview(self.refreshControl)
    }
    
    //if the view did appear refresh it
    override func viewWillAppear(_ animated: Bool) {
        refresh(self)
    }
    
    //function for refreshing the ministry team list
    func refresh(_ sender: AnyObject) {
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
            self.ministryTeams.append(ministryTeam as NSDictionary)
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
    fileprivate func hideMinistryTableView(_ isHidden: Bool) {
        if isHidden {
            joinMTeamView.isHidden = false
            ministryTeamView.isHidden = true
        }
        else {
            ministryTeamView.isHidden = false
            joinMTeamView.isHidden = true
        }
    }
    
    //navigates to the ministry teams list
    @IBAction func onTouchSeeMore(_ sender: AnyObject) {
        let vc = MinistryTeamsCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(vc, animated: true)
    }

    /* Table View Delegate code */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministryTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // your cell coding
        let cell = tableView.dequeueReusableCell(withIdentifier: "ministryTeam") as! JoinedTeamsTableViewCell
        let ministryTeam = ministryTeams[indexPath.item]
        cell.ministryTeam = ministryTeam
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ministryTeam = ministryTeams[indexPath.item]
        
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "MinistryTeamDetailViewController") as! MinistryTeamDetailViewController
        viewController.ministryTeamDict = ministryTeam
        viewController.listVC = self
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func unwindToMinistryTeamsList(_ segue: UIStoryboardSegue) {
        refresh(self)
    }
}
