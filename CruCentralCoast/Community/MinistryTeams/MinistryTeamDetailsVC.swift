//
//  MinistryTeamDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import MessageUI

class MinistryTeamDetailsVC: UIViewController, MFMessageComposeViewControllerDelegate{
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var leaderNamesLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var leaderPhoneNumbers : [String] = []
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func didPressCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func joinMinistryTeam() {
        if MFMessageComposeViewController.canSendText() {
            if self.leaderPhoneNumbers.isEmpty {
                self.presentAlert(title: "Can't contact Leader", message: "Sorry, there is no phone number listed for this Ministry Team")
            } else {
                let controller = MFMessageComposeViewController()
                controller.body = "Hey I'm interested in joining your Ministry Team!"
                controller.recipients = self.leaderPhoneNumbers
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        } else {
            print("error can't send text")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func configure(with ministryTeam: MinistryTeam) {
        DispatchQueue.main.async {
            self.nameLabel.text = ministryTeam.name
            self.movementLabel.text = ministryTeam.movement?.name.uppercased()
            self.leaderNamesLabel.text = "Leaders: \(ministryTeam.leaderNames ?? "N/A")"
            self.summaryLabel.text = ministryTeam.summary
            self.bannerImageView.downloadedFrom(link: ministryTeam.imageLink, contentMode: .scaleAspectFill)
            
            self.leaderPhoneNumbers = ministryTeam.leaders.filter({ $0.phone != nil }).compactMap({ $0.phone! })
        }
    }
}
