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
import AlamofireImage

class CommunityGroupsTabVC: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var joinButton: UIButton!
    
    private var groups = [CommunityGroup]()
    //private var communityGroupsStorageManager: MapLocalStorageManager!
    private var selectedGroup: CommunityGroup?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        //Set the cells for automatic cell height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.backgroundColor = Colors.googleGray
        
        //set up storage managers for ministry teams and for storing/loading user information
//        communityGroupsStorageManager = MapLocalStorageManager(key: Config.CommunityGroupsStorageKey)
        
        

    }

    public func loadCommunityGroups() {
        guard let groupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let groupArray = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as? [CommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        groups = groupArray
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Load Community Groups from local storage
        loadCommunityGroups()
        self.tableView.reloadData()
    }
 
    // MARK: - XLPagerTabStrip Stuff
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "COMMUNITY GROUPS")
    }
    
    // MARK: - Empty Data Set Functions
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        self.tableView.backgroundColor = UIColor.white
        return UIImage(named: Config.noCommunityGroupsImage)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        self.tableView.reloadData()
    }
    

    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if groups.count > 0 {
            self.tableView.backgroundColor = Colors.googleGray
        }
        return groups.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if groups[indexPath.row].imgURL != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! CommunityGroupTabCell
            
            //Load image or get from cache
            print("Loading image from: " + groups[indexPath.row].imgURL)
            let urlRequest = URLRequest(url: URL(string: groups[indexPath.row].imgURL)!)
            CruClients.getImageUtils().getImageDownloader().download(urlRequest) { response in
                if let image = response.result.value {
                    cell.groupImage.image = image
                }
            }

            // Configure the cell...
            if let parentMin = groups[indexPath.row].parentMinistryName as? String {
                cell.ministryLabel.text = parentMin
            }
            else {
                cell.ministryLabel.text = "Unknown"
            }
            
            cell.meetingTimeLabel.text = groups[indexPath.row].getMeetingTime()
            
            cell.leaderLabel.text = groups[indexPath.row].getLeaderString()
            cell.roleLabel.text = groups[indexPath.row].role.uppercased()
            if groups[indexPath.row].role == "leader" {
                cell.roleLabel.textColor = CruColors.darkBlue
            }
            
            //Add drop shadow
            cell.backgroundColor = Colors.googleGray
            cell.cardView.layer.shadowColor = UIColor.black.cgColor
            cell.cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.cardView.layer.shadowOpacity = 0.25
            cell.cardView.layer.shadowRadius = 2
            
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell2", for: indexPath) as! CommunityGroupNoImageTabCell
            
            // Configure the cell...
            if let parentMin = groups[indexPath.row].parentMinistryName as? String {
                cell.ministryLabel.text = parentMin
            }
            else {
                cell.ministryLabel.text = "Unknown"
            }
            
            cell.meetingTimeLabel.text = groups[indexPath.row].getMeetingTime()
            
            cell.leaderLabel.text = groups[indexPath.row].getLeaderString()
            cell.roleLabel.text = groups[indexPath.row].role.uppercased()
            
            //Add drop shadow
            cell.backgroundColor = Colors.googleGray
            cell.cardView.layer.shadowColor = UIColor.black.cgColor
            cell.cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.cardView.layer.shadowOpacity = 0.25
            cell.cardView.layer.shadowRadius = 2
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let group = groups[indexPath.row]
        
        if group.imgURL == "" {
            //return 194.0
            return 153
        }
        else {
            return 300
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "communitygroups", bundle: nil)
        let detailsVC = storyBoard.instantiateViewController(withIdentifier: "detailVC") as! CommunityGroupDetailsViewController
        detailsVC.group = groups[indexPath.row]
        selectedGroup = groups[indexPath.row]
        self.navigationController?.pushViewController(detailsVC, animated: true)
        //self.present(detailsVC, animated: true, completion: nil)
        
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "listSegue" {
            if let vc = segue.destination as? CommunityGroupsListTableViewController {
                vc.joinedGroups = self.groups
            }
        }
    }

}
