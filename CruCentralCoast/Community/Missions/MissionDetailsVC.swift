//
//  MissionDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/8/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import SafariServices

class MissionDetailsVC: UIViewController {
    
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var missionURLString: String?
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
    }

    @IBAction func didPressCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func learnMore() {
        // TODO
        
        if let url = URL(string: missionURLString!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            let config = SFSafariViewController.Configuration()
//            config.entersReaderIfAvailable = true
//
//            let vc = SFSafariViewController(url: url, configuration: config)
//            self.present(vc, animated: true)
        }
        
//        self.presentAlert(title: "Learn More", message: "Coming Soon...")
    }
    
    func configure(with mission: Mission) {
        DispatchQueue.main.async {
            self.dateLabel.text = (mission.startDate.toString(dateStyle: .medium, timeStyle: .none) + " - " + mission.endDate.toString(dateStyle: .medium, timeStyle: .none)).uppercased()
            self.nameLabel.text = mission.name
            self.locationLabel.text = mission.location?.string
            self.summaryLabel.text = mission.summary
            self.bannerImageView.downloadedFrom(link: mission.imageLink, contentMode: .scaleAspectFill)
            self.missionURLString = mission.url
        }
    }
}
