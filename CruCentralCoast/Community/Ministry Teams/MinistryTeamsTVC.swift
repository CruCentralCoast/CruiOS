//
//  MinistryTeamsTVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/30/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MinistryTeamsTVC: UITableViewController {
    
    //test data array
    var testDataArray: [MinistryCellParameters] = [MinistryCellParameters(teamTitle: "Software Dev Team", teamLeaders: ["Landon Gerrits", "Tyler Dahl"], teamDescription: "description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescription... description...description... description...cription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripti"), MinistryCellParameters(teamTitle: "Graphic Design Team", teamLeaders: ["Annamarie"], teamDescription: "description...")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let nib = UINib.init(nibName: "CommunityTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "comCell")
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return testDataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "MinistryTeamDetails", bundle: nil).instantiateViewController(withIdentifier: "MinistryTeamDetailsVC") as? MinistryTeamDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        vc.configure(with: self.testDataArray[indexPath.row])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comCell", for: indexPath) as! CommunityTableViewCell
        
        
        // Configure the cell
        cell.bigLabel.text = testDataArray[indexPath.row].teamTitle
        cell.bannerImage.image = testDataArray[indexPath.row].teamImage
        //only returning first team name
        cell.smallLabel1.text = testDataArray[indexPath.row].teamLeaders[0]
        
        
        
        return cell
    }

}
