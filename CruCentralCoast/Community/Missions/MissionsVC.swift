//
//  MissionsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 6/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class MissionsVC: UITableViewController {
    
    var dataArray: Results<Mission>!

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "MissionDetails", bundle: nil).instantiateViewController(MissionDetailsVC.self)
//        vc.configure(with: self.dataArray[indexPath.row])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CommunityGroupCell.self, indexPath: indexPath)
        
//        cell.bigLabel.text = self.dataArray[indexPath.row].titleLabel
//        cell.bannerImage.image = self.dataArray[indexPath.row].image
//        cell.smallLabel1.text = self.dataArray[indexPath.row].location
//        cell.smallLabel2.text = self.dataArray[indexPath.row].date
        
        return cell
    }
}
