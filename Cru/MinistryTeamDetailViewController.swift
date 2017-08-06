//
//  MinistryTeamDetailViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 4/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamDetailViewController: UIViewController {

    @IBOutlet weak var ministryTeamNameLabel: UILabel!
    @IBOutlet weak var ministryTeamImage: UIImageView!
    @IBOutlet weak var ministryTeamDescription: UITextView!
    @IBOutlet weak var ministryNameLabel: UILabel!
    
    //constraint for ministry team name to superview
    @IBOutlet weak var heightFromLabelToSuperView: NSLayoutConstraint!
    
    //storage manager
    var teamStorageManager: MapLocalStorageManager<MinistryTeam>!
    
    //ministry team reference dictionary for the id
//    var ministryTeamDict: NSDictionary!
    var ministryTeam: MinistryTeam!
    
    //reference to previous vc
    var listVC: MinistryTeamViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let ministryTeamId = ministryTeamDict["id"] as! String
//        CruClients.getServerClient().getById(.MinistryTeam, insert: insertMinistryTeam, completionHandler: completeMinistryTeamInsert, id: ministryTeamId)
        
        teamStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
    }
    
    //inserts the ministry team we're looking for into the current view
    func insertMinistryTeam(_ dict: NSDictionary) {
        self.ministryTeam = MinistryTeam(dict: dict)!
    }
    
    func completeMinistryTeamInsert(_ isSuccess: Bool) {
        if isSuccess {
            ministryTeamNameLabel.text = ministryTeam.ministryName
            
            if ministryTeam.imageUrl == "" {
                heightFromLabelToSuperView.constant = 8.0
            }
            else {
                //ministryTeamImage.load(ministryTeam.imageUrl)
                ministryTeamImage.load.request(with: ministryTeam.imageUrl)
            }
            
            var description = ministryTeam.description
            description += "\n\n\nLeader Information:\n\n"
            
            if ministryTeam.leaders.count > 0 {
                for leader in ministryTeam.leaders {
                    description += leader.name + "   -   " + GlobalUtils.formatPhoneNumber(leader.phone)
                }
            }
            else {
                description += "N/A"
            }
            
            ministryTeamDescription.text = description
            
            //grab ministry name
            CruClients.getServerClient().getById(.Ministry, insert: {
                ministry in
                if let ministryName = ministry["name"] as? String {
                    self.ministryNameLabel.text = ministryName
                }
                else {
                    self.ministryNameLabel.text = "N/A"
                }
                }, completionHandler: {_ in }, id: ministryTeam.parentMinistry)
        }
        else {
            //show server error view
        }
    }
    
    //leaves the ministry team
    @IBAction func leaveMinistryTeam(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Leaving Ministry Team", message: "Are you sure you would like to leave this Ministry Team?", preferredStyle: UIAlertControllerStyle.alert)
        
        //add alert box actions
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: unwindToMinistryTeamList))
        
        //present the alert box
        self.present(alert, animated: true, completion: nil)
    }
    
    func unwindToMinistryTeamList(_ action: UIAlertAction){
        teamStorageManager.removeElement(ministryTeam.id)
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
            
            if (listVC != nil){
                listVC?.refresh(self)
            }
            
        }
    }
}
