//
//  CommunityGroupDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 7/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import MessageUI

class CommunityGroupDetailsVC: UIViewController, MFMessageComposeViewControllerDelegate {

    

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var leaderNamesLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var contactLeaderButton: UIButton!
    @IBOutlet weak var joinCommunityGroupButton: CruButton!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    var leaderPhoneNumbers : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        
    }
    
    @IBAction func joinCommunityGroup() {
        // TODO
        self.presentAlert(title: "Join Community Group", message: "Coming Soon...")
    }
    
    @IBAction func didTapContactLeader() {
        if MFMessageComposeViewController.canSendText() {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey I'm interested in joining your community group!"
            controller.recipients = self.leaderPhoneNumbers
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            print("error cant send text")
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func configure(with communityGroup: CommunityGroup) {
        DispatchQueue.main.async {
            self.genderLabel.text = communityGroup.gender.rawValue.uppercased()
            self.dayLabel.text = communityGroup.weekDay.rawValue.uppercased()
            self.timeLabel.text = communityGroup.time
            self.nameLabel.text = communityGroup.name
            self.yearLabel.text = communityGroup.year.rawValue.uppercased()
            self.movementLabel.text = communityGroup.movement?.name
            self.leaderNamesLabel.text = "Leaders: \(communityGroup.leaderNames ?? "N/A")"
            self.summaryLabel.text = communityGroup.summary
            
            self.joinCommunityGroupButton.isHidden = true
            
            for leader in communityGroup.leaders {
                if let phoneNumber = leader.phone{
                    self.leaderPhoneNumbers.append(phoneNumber)
                }
            }

            self.bannerImageView.downloadedFrom(link: communityGroup.imageLink, contentMode: .scaleAspectFill)
            // If no image link exists, remove the image's size constraint
            self.imageViewAspectRatioConstraint.isActive = (communityGroup.imageLink != nil && !communityGroup.imageLink!.isEmpty)
        }
    }
}
