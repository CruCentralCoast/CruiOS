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

class SummerMissionsTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    fileprivate var missions = [SummerMission]()
    fileprivate var hasConnection = true
    fileprivate let reuseIdentifier = "missionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup side menu
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)
        
        // Configure nav bar
        self.navigationItem.title = "Summer Missions"
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        // Start animating the loading overlay
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        
        // Check for connection then download data
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        // Log Firebase Analytics Event
        Analytics.logEvent("Summer_missions_loaded", parameters: nil)
    }
    
    // MARK: - Helper Functions
    func finishConnectionCheck(_ connected: Bool){
        self.tableView!.emptyDataSetSource = self
        self.tableView!.emptyDataSetDelegate = self
        self.hasConnection = connected
        
        if !connected {
            self.tableView!.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        } else {
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
    
    // MARK: - Table View Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return missions.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mission = self.missions[indexPath.row]
        
        if mission.imageLink.isEmpty {
            return 125
        } else {
            return 275
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! SummerMissionsTableViewCell
        
        let mission = missions[indexPath.row]
        cell.mission = mission

        return cell
    }
    
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
}

// MARK: - SWRevealViewControllerDelegate
extension SummerMissionsTableViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.left {
            self.tableView.isScrollEnabled = true
            
            for view in self.tableView.subviews {
                view.isUserInteractionEnabled = true
            }
        } else if position == FrontViewPosition.right {
            self.tableView.isScrollEnabled = false
            
            for view in self.tableView.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
}

// MARK: - Empty DataSet Delegate Functions
extension SummerMissionsTableViewController: DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        guard !self.hasConnection else { return }

        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        guard !self.hasConnection else { return nil }
        
        return UIImage(named: Config.noConnectionImageName)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        guard !self.hasConnection else { return nil }
        
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "Sorry, we're working on it! Check back later for more information about summer missions.", attributes: attributes)
    }
}
