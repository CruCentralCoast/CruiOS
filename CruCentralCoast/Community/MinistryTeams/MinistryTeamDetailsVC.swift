//
//  MinistryTeamDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class MinistryTeamDetailsVC: UIViewController {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var leaderNamesLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
    }

    @IBAction func joinMinistryTeam() {
        // TODO
        self.presentAlert(title: "Join Ministry Team", message: "Coming Soon...")
    }
    
    func configure(with ministryTeam: MinistryTeam) {
        DispatchQueue.main.async {
            self.nameLabel.text = ministryTeam.name
            self.movementLabel.text = ministryTeam.movement?.name
            self.leaderNamesLabel.text = "Leaders: \(ministryTeam.leaderNames ?? "N/A")"
            self.summaryLabel.text = ministryTeam.summary
            // Try to download the image, but only display it if this cell has not been reused
            if let imageLink = ministryTeam.imageLink {
                ImageManager.instance.fetch(imageLink) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.bannerImageView.image = image
                    }
                }
            }
        }
    }
}
