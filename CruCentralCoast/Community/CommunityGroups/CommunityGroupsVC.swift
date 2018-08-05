//
//  CommunityGroupsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class CommunityGroupsVC: UITableViewController {
    
    var dataArray: Results<CommunityGroup>!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(CommunityGroupCell.self)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CommunityGroupCell.self, indexPath: indexPath)
        
        cell.bannerImage.image = #imageLiteral(resourceName: "placeholder.jpg")
        cell.bigLabel.text = "big label"
        cell.smallLabel1.text = "label1"
        cell.smallLabel2.text = "label2"

        return cell
    }
}
