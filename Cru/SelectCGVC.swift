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
    fileprivate var ministry: String!
    fileprivate var answers = [[String:String]]()
    
    
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose a Community Group"
        table.estimatedRowHeight = 250.0
        table.rowHeight = UITableViewAutomaticDimension
        loadCommunityGroups()
    }
    
    fileprivate func loadCommunityGroups() {
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        
        
        
        //load all community groups until the submit answers endpoint is added
        
        let params = ["answers":answers]
        CruClients.getServerClient().postDataIn(DBCollection.Ministry, parentId: ministry,
            child: DBCollection.CommunityGroup, params: params, insert: insertGroup, completionHandler: finishInserting)
        //CruClients.getServerClient().getData(.CommunityGroup, insert: insertGroup, completionHandler: finishInserting)
    }
    
    fileprivate func finishInserting(_ success: Bool) {
        groups.sort()
        table.reloadData()
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }
    
    fileprivate func insertGroup(_ dict: NSDictionary) {
        //let cell = self.table.dequeueReusableCell(withIdentifier: "cell")!
        let group = CommunityGroup(dict: dict)
        groups.append(group)
        
    }
    
    func setAnswers(_ answers: [[String:String]]) {
        self.answers = answers
    }
    
    func setMinistry(_ ministryId: String) {
        self.ministry = ministryId
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //load cell and ride associated with that cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommunityGroupCell
        let group = groups[indexPath.row]
        
        
        
        cell.setGroup(group)
        cell.setSignupCallback(jumpBackToGetInvolved)
        cgs.append(cell)
        
        return cell
        
    }
    
    func jumpBackToGetInvolved() {
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKind(of: GetInvolvedViewController.self) {
                _ = self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
}
