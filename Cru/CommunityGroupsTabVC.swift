//
//  CommunityGroupsTableViewController.swift
//  Cru
//
//  The view controller class for the Community Groups tab, set up using 
//  the instructions at https://medium.com/michaeladeyeri/how-to-implement-android-like-tab-layouts-in-ios-using-swift-3-578516c3aa9 .
//
//  Created by Erica Solum on 8/5/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet

class CommunityGroupsTabVC: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinButton: UIButton!
    
    private var groups = [StoredCommunityGroup]()
    private var communityGroupsStorageManager: MapLocalStorageManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        //Set the cells for automatic cell height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.backgroundColor = Colors.googleGray
        
        //set up storage managers for ministry teams and for storing/loading user information
        communityGroupsStorageManager = MapLocalStorageManager(key: Config.CommunityGroupsStorageKey)
        //Load Community Groups from local storage
        loadCommunityGroups()

    }

    public func loadCommunityGroups() {
        /*let joinedGroupIds = communityGroupsStorageManager.getKeys()
        print("Joined groups:")
        print(joinedGroupIds)
        if let group = communityGroupsStorageManager.getDataObject(Config.CommunityGroupsStorageKey) as? CommunityGroup {
            groups.append(group)
            print("Appending a group")
        }*/
        
        guard let groupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let groupArray = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as? [StoredCommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        for group in groupArray {
            print("")
            print("group.id: \(group.id)")
            print("group.desc: \(group.desc)")
            print("place.parentMinistry: \(group.parentMinistry)")
            groups.append(group)
        }
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCommunityGroups()
        self.tableView.reloadData()
    }
 
    // MARK: - XLPagerTabStrip Stuff
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "COMMUNITY GROUPS")
    }
    
    // MARK: - Empty Data Set Functions
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: Config.noCommunityGroupsImage)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        self.tableView.reloadData()
    }
    

    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return groups.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! CommunityGroupTabCell
     
        // Configure the cell...
        if let parentMin = groups[indexPath.row].parentMinistry as? String {
            cell.ministryLabel.text = parentMin
        }
        else {
            cell.ministryLabel.text = "Unknown"
        }
        
        cell.meetingTimeLabel.text = groups[indexPath.row].stringTime
        
        cell.leaderLabel.text = groups[indexPath.row].getLeaderString()
        
        if groups[indexPath.row].imgURL != "" {
            cell.groupImage.load.request(with: groups[indexPath.row].imgURL)
        }
        else {
            cell.groupImage.isHidden = true
            cell.leaderTopConstraint.constant = 12
        }
        
        //Add drop shadow
        cell.backgroundColor = Colors.googleGray
        cell.cardView.layer.shadowColor = UIColor.black.cgColor
        cell.cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.cardView.layer.shadowOpacity = 0.25
        cell.cardView.layer.shadowRadius = 2
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let group = groups[indexPath.row]
        
        if group.imgURL == "" {
            //return 194.0
            return 154
        }
        else {
            return 300
        }
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
