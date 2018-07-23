//
//  MissionsTableViewController.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 6/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MissionsTableVC: UITableViewController {
    
    var dataArray = [Missions]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true

        self.tableView.registerCell(CommunityTableViewCell.self)
        
        DatabaseManager.instance.getMission{ (mission) in
            self.dataArray = mission
            for mission in self.dataArray {
                UIImage.downloadedFrom(link: mission.imageLink, completion: { (image) in
                    mission.image = image
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
            self.tableView.reloadData()
        }
 
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
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "MissionDetails", bundle: nil).instantiateViewController(withIdentifier: "MissionDetailsVC") as? MissionDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityTableViewCell", for: indexPath) as! CommunityTableViewCell
        
        
        // Configure the cell
        cell.bigLabel.text = dataArray[indexPath.row].name
        cell.bannerImage.image = dataArray[indexPath.row].image
        cell.smallLabel1.text = dataArray[indexPath.row].startDate.toString(dateFormat: "MMM-dd-yyyy")
        cell.smallLabel2.text = "unused label"
        
        
        return cell
    }
    
    
}
