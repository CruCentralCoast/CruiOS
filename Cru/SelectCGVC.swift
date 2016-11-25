//
//  SelectCGVC.swift
//  Cru
//
//  Created by Max Crane on 5/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//
import MRProgress
import UIKit

class SelectCGVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var cgs = [CommunityGroupCell]()
    var groups = [CommunityGroup]()
    private var ministry: String!
    private var answers = [[String:String]]()
    
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a Community Group"
        table.estimatedRowHeight = 250.0
        table.rowHeight = UITableViewAutomaticDimension
        loadCommunityGroups()
    }
    
    private func loadCommunityGroups() {
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        
        
        
        //load all community groups until the submit answers endpoint is added
        
        let params = ["answers":answers]
        CruClients.getServerClient().postDataIn(DBCollection.Ministry, parentId: ministry,
            child: DBCollection.CommunityGroup, params: params, insert: insertGroup, completionHandler: finishInserting)
        //CruClients.getServerClient().getData(.CommunityGroup, insert: insertGroup, completionHandler: finishInserting)
    }
    
    private func finishInserting(success: Bool) {
        groups.sortInPlace()
        table.reloadData()
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }
    
    private func insertGroup(dict: NSDictionary) {
        let cell = self.table.dequeueReusableCellWithIdentifier("cell")!
        let group = CommunityGroup(dict: dict)
        groups.append(group)
        
    }
    
    func setAnswers(answers: [[String:String]]) {
        self.answers = answers
    }
    
    func setMinistry(ministryId: String) {
        self.ministry = ministryId
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //load cell and ride associated with that cell
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CommunityGroupCell
        let group = groups[indexPath.row]
        
        
        
        cell.setGroup(group)
        cell.setSignupCallback(jumpBackToGetInvolved)
        cgs.append(cell)
        
        return cell
        
    }
    
    func jumpBackToGetInvolved() {
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKindOfClass(GetInvolvedViewController) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
}
