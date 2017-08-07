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
    
    var ministryTeamsStorageManager: MapLocalStorageManager<MinistryTeam>!
    var ministryTeam: MinistryTeam! {
        didSet {
            if self.isViewLoaded {
                self.updateViewsForMinistryTeam()
            }
        }
    }
    
    //reference to previous vc
    var listVC: MinistryTeamViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update the view controller to show the ministry team info
        self.updateViewsForMinistryTeam()
        
        // Setup local storage manager
        self.ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
    }
    
    private func updateViewsForMinistryTeam() {
        self.ministryTeamNameLabel.text = self.ministryTeam.name
        
        if self.ministryTeam.imageUrl == "" {
            self.ministryTeamImage.image = #imageLiteral(resourceName: "fall-retreat-still")
        } else if self.ministryTeam.image == nil {
            self.ministryTeamImage.load.request(with: self.ministryTeam.imageUrl, onCompletion: { (image, error, operation) in
                self.ministryTeam.image = self.ministryTeamImage.image
            })
        } else {
            self.ministryTeamImage.image = self.ministryTeam.image
        }
        
        var description = self.ministryTeam.summary
        description += "\n\n\nLeader Information:\n\n"
        
        if self.ministryTeam.leaders.count > 0 {
            for leader in self.ministryTeam.leaders {
                description += leader.name + "   -   " + GlobalUtils.formatPhoneNumber(leader.phone)
            }
        } else {
            description += "N/A"
        }
        
        self.ministryTeamDescription.text = description
        
        //grab ministry name
        CruClients.getServerClient().getById(.Ministry, insert: { ministry in
            if let ministryName = ministry["name"] as? String {
                self.ministryNameLabel.text = ministryName
            } else {
                self.ministryNameLabel.text = "N/A"
            }
        }, completionHandler: { _ in }, id: self.ministryTeam.parentMinistry)
    }
    
    @IBAction func leaveMinistryTeam(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Leaving Ministry Team", message: "Are you sure you would like to leave this Ministry Team?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: self.unwindToMinistryTeamList))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func unwindToMinistryTeamList(_ action: UIAlertAction) {
        self.ministryTeamsStorageManager.removeElement(self.ministryTeam.id)
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
            
            if (listVC != nil){
                listVC?.refresh(self)
            }
        }
    }
}
