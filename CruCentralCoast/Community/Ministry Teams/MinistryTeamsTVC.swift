//
//  MinistryTeamsTVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/30/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MinistryTeamsTVC: UITableViewController {
    
    var dataArray = [MinistryTeam]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.registerCell(CommunityTableViewCell.self)
        
        DatabaseManager.instance.getMinistryTeam{ (ministryTeam) in
            self.dataArray = ministryTeam
            for ministryTeam in self.dataArray {
                UIImage.downloadedFrom(link: ministryTeam.imageLink!, completion: { (image) in
                    ministryTeam.image = image
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
            self.tableView.reloadData()
        }
        
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
        guard let vc = UIStoryboard(name: "MinistryTeamDetails", bundle: nil).instantiateViewController(withIdentifier: "MinistryTeamDetailsVC") as? MinistryTeamDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueCell(CommunityTableViewCell.self, indexPath: indexPath)
        
        cell.bigLabel.text = dataArray[indexPath.row].name
        cell.bannerImage.image = dataArray[indexPath.row].image
        
        // leaders still has database reference issue
        cell.smallLabel1.text = "Team Leader Names"
        cell.smallLabel2.text = "unused label"
        
        cell.selectionStyle = .none
        
        
        return cell
    }

}
