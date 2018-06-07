//
//  MissionsTableViewController.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 6/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MissionsTableVC: UITableViewController {
    
    //test data array
    var testDataArray: [MissionCellParameters] = [MissionCellParameters(titleLabel: "Oasis", date: "11/11/11", location: "test location", description: "test description"),MissionCellParameters(titleLabel: "Oasis", date: "11/11/11", location: "test location", description: "test description"),MissionCellParameters(titleLabel: "Oasis", date: "11/11/11", location: "test location", description: "test description"),MissionCellParameters(titleLabel: "Oasis", date: "11/11/11", location: "test location", description: "test description"),MissionCellParameters(titleLabel: "Oasis", date: "11/11/11", location: "test location", description: "test description"),MissionCellParameters(titleLabel: "Oasis", date: "11/11/11", location: "test location", description: "test description")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the cell...
        let nib = UINib.init(nibName: "CommunityTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "comCell")

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
        return testDataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 260
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "MissionDetails", bundle: nil).instantiateViewController(withIdentifier: "MissionDetailsVC") as? MissionDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        vc.configure(with: self.testDataArray[indexPath.row])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comCell", for: indexPath) as! CommunityTableViewCell
        
        
        // Configure the cell
        cell.bigLabel.text = testDataArray[indexPath.row].titleLabel
        cell.bannerImage.image = testDataArray[indexPath.row].image
        cell.smallLabel1.text = testDataArray[indexPath.row].location
        cell.smallLabel2.text = testDataArray[indexPath.row].date
        
        
        return cell
    }
    
    
}
