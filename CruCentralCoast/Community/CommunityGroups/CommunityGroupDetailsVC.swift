//
//  CommunityGroupDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 7/5/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityGroupDetailsVC: UIViewController {

    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var leaderNamesLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    @IBAction func joinCommunityGroup() {
        // TODO
        self.presentAlert(title: "Join Community Group", message: "Coming Soon...")
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
            // If no image link exists, remove the image's size constraint
            self.imageViewAspectRatioConstraint.isActive = (communityGroup.imageLink != nil && !communityGroup.imageLink!.isEmpty)
            // Try to download the image, but only display it if this cell has not been reused
            if let imageLink = communityGroup.imageLink {
                ImageManager.instance.fetch(imageLink) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.bannerImageView.image = image
                    }
                }
            }
        }
    }
}
