//
//  SummerMissionsTableViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 5/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import MRProgress

class SummerMissionsTableViewController: UITableViewController, SWRevealViewControllerDelegate, DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var hasConnection = true
    
    var missions = [SummerMission]()
    fileprivate let reuseIdentifier = "missionCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        //Check for connection then load events in the completion function
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        
        navigationItem.title = "Summer Missions"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    // MARK: - Helper Functions
    //Test to make sure there is a connection then load missions
    func finishConnectionCheck(_ connected: Bool){
        self.tableView!.emptyDataSetSource = self
        self.tableView!.emptyDataSetDelegate = self
        
        if(!connected){
            hasConnection = false
            //Display a message if no connection
            
            self.tableView!.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            //hasConnection = false
        }else{
            hasConnection = true
            //API call to load missions
            CruClients.getServerClient().getData(DBCollection.SummerMission, insert: insertMission, completionHandler: reload)
            
        }
        
    }

    // Creates and inserts a SummerMission into this collection view from the given dictionary.
    func insertMission(_ dict : NSDictionary) {
        self.missions.append(SummerMission(dict: dict)!)
    }
    
    // Signals the collection view to reload data.
    func reload(_ success: Bool) {
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.reloadData()
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    // MARK: - Empty Data Set Functions
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if !hasConnection {
            CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        }
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if hasConnection {
            return nil
        }
        else {
            return UIImage(named: Config.noConnectionImageName)
        }
        
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if hasConnection {
            return nil
        }
        else {
            let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
            return NSAttributedString(string: "Sorry, we're working on it! Check back later for more information about summer missions.", attributes: attributes)
        }
    }
    
    
    // MARK: - Table View Delegate Functions

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return missions.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mission = missions[indexPath.row]
        
        if mission.imageLink == "" {
            return 150.0
        }
        else {
            return 275.0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! SummerMissionsTableViewCell
        let mission = missions[indexPath.row]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.mission = mission
        
        cell.card.layer.shadowColor = UIColor.black.cgColor
        cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.card.layer.shadowOpacity = 0.25
        cell.card.layer.shadowRadius = 2

        return cell
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "missionDetails" {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            let missionDetailViewController = segue.destination as! SummerMissionDetailController
            let selectedMissionCell = sender as! SummerMissionsTableViewCell
            let indexPath = self.tableView!.indexPath(for: selectedMissionCell)!
            let selectedMission = missions[indexPath.row]
            
            missionDetailViewController.uiImage = selectedMissionCell.missionImage?.image
            missionDetailViewController.mission = selectedMission
            missionDetailViewController.dateText = selectedMissionCell.missionDateLabel.text!
        }
    }
    
    //reveal controller function for disabling the current view
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
        if position == FrontViewPosition.left {
            self.tableView.isScrollEnabled = true
            
            for view in self.tableView.subviews {
                view.isUserInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.right {
            self.tableView.isScrollEnabled = false
            
            for view in self.tableView.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
}
