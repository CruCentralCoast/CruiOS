//
//  CommunityGroupsTVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 5/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityGroupsTVC: UITableViewController {
    
    
    
    var dataArray = [CommunityGroup]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.registerCell(CommunityTableViewCell.self)
        
        DatabaseManager.instance.getCommunityGroup { (communityGroups) in
            self.dataArray = communityGroups
            for communityGroup in self.dataArray {
                UIImage.downloadedFrom(link: communityGroup.imageLink, completion: { (image) in
                    communityGroup.image = image
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
        guard let vc = UIStoryboard(name: "CommunityGroupDetails", bundle: nil).instantiateViewController(withIdentifier: "CommunityGroupDetails") as? CommunityGroupDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
         self.navigationController?.present(vc, animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(CommunityTableViewCell.self, indexPath: indexPath)        
        
        //cell.bannerImage.image = UIImage(named: dataArray[indexPath.row].imageLink!)
        
        // i think i need to do a compact map or something here to get all strings in leader array
        cell.bigLabel.text = dataArray[indexPath.row].name
        
        let array = [dataArray[indexPath.row].dayOfWeek, dataArray[indexPath.row].meetingTime]
        let dayAndTime = array.compactMap { $0 }
        cell.smallLabel1.text = dayAndTime.joined(separator: ", ")
        cell.smallLabel2.text = dataArray[indexPath.row].type
        
        //test
        
        cell.selectionStyle = .none

        return cell
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
