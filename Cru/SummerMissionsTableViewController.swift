//
//  SummerMissionsTableViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 5/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet


class SummerMissionsTableViewController: UITableViewController, SWRevealViewControllerDelegate, DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var missions = [SummerMission]()
    fileprivate let reuseIdentifier = "missionCell"

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: Config.noConnectionImageName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)
        
        CruClients.getServerClient().getData(DBCollection.SummerMission, insert: insertMission, completionHandler: reload)
        
        navigationItem.title = "Summer Missions"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
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
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        CruClients.getServerClient().getData(DBCollection.SummerMission, insert: insertMission, completionHandler: reload)
    }

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
