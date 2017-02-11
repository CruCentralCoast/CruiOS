//
//  DisplayCGVC.swift
//  Cru
//
//  Created by Peter Godkin on 5/26/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class DisplayCGVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var leaders = [CGLeaderCell]()
    var group: CommunityGroup!
    var cells = [UITableViewCell]()
    @IBOutlet weak var table: UITableView!
    var leaveCallback: ((Void)->Void)!
    var ministryNameCell: UITextView!

    @IBAction func leaveGroup(_ sender: AnyObject) {
        cells.removeAll()
        self.table.reloadData()
        GlobalUtils.saveString(Config.communityGroupKey, value: "")
        leaveCallback()
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        let groupId = GlobalUtils.loadString(Config.communityGroupKey)
        if (groupId != "") {
            loadCommunityGroup(groupId)
        }
        
        
        table.estimatedRowHeight = 300
        table.rowHeight = UITableViewAutomaticDimension
    }

    fileprivate func loadCommunityGroup(_ id: String) {
        CruClients.getServerClient().getById(DBCollection.CommunityGroup, insert: insertGroup, completionHandler: { success in
            
                self.table.reloadData()
            
            
            
            
            }, id: id)
    }
    fileprivate func insertMinistry(_ dict: NSDictionary){
        let minist = Ministry(dict: dict)
        ministryNameCell.text = minist.name
    }

    fileprivate func insertGroup(_ dict: NSDictionary) {
        group = CommunityGroup(dict: dict)
        
        if(group.parentMinistry != nil){
            CruClients.getServerClient().getById(.Ministry, insert: insertMinistry, completionHandler: {
                success in
                }, id: group.parentMinistry)
        }
        
        
        if let cell = table.dequeueReusableCell(withIdentifier: "cell")! as? CGDetailTableViewCell{
            cell.cellTitle.text = "Meeting Time:"
            cell.cellValue.text = group.getMeetingTime()
            cells.append(cell)
            table.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }
        
        if let cell = table.dequeueReusableCell(withIdentifier: "cell")! as? CGDetailTableViewCell{
            cell.cellTitle.text = "Name:"
            cell.cellValue.text = group.name
            cells.append(cell)
            table.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }
        
        if let cell = table.dequeueReusableCell(withIdentifier: "cell")! as? CGDetailTableViewCell{
            cell.cellTitle.text = "Description:"
            cell.cellValue.text = group.description
            cells.append(cell)
            table.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }
        
        if let cell = table.dequeueReusableCell(withIdentifier: "cell")! as? CGDetailTableViewCell{
            cell.cellTitle.text = "Ministry:"
            ministryNameCell = cell.cellValue
            cell.cellValue.text = ""
            cells.append(cell)
            table.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }
        
        for lead in group.leaders{
            if let cell = self.table.dequeueReusableCell(withIdentifier: "leaderCell")! as? CGLeaderCell{
                cell.setUser(lead)
                cells.append(cell)
                table.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
            }
        }
        
        
        self.table.reloadData()
    }
    
    fileprivate func finishInserting(_ success: Bool) {
        table.reloadData()
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.row]
    }
    
//    func setLeaveCallback(callback: Void->Void) {
//        leaveCallback = callback
//    }

}
