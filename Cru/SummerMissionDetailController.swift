//
//  SummerMissionDetailController.swift
//  Cru
//
//  Created by Quan Tran on 11/25/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import EventKit

class SummerMissionDetailController: UIViewController {
    
    @IBOutlet fileprivate weak var image: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var datesLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionView: UITextView!
    @IBOutlet fileprivate weak var locationLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    
    fileprivate let COVER_ALPHA: CGFloat = 0.35
    var uiImage: UIImage!
    var mission: SummerMission!
    var dateText = ""
    
    override func viewWillDisappear(_ animated: Bool) {
        image.image = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let mission = mission {
            navigationItem.title = "Details"
            
            //self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
            image.image = uiImage
            
            //image.load(mission.imageLink)
            
            datesLabel.text = dateText
            titleLabel.text = mission.name
            titleLabel.sizeToFit()
            locationLabel.text = mission.getLocationString()
            
            
            descriptionView.text = mission.description
            descriptionView.sizeToFit()
            //topCoverView.alpha = COVER_ALPHA
            
            //log Firebase Analytics Event
            Analytics.logEvent("Summer_missions_loaded", parameters: nil)
        }
        
        self.image.image = uiImage
        
        // Hide the Learn More button if there is no url
        self.learnMoreButton.isHidden = self.mission.url.isEmpty
    }
    
    @IBAction func learnMoreButton(_ sender: UIButton) {
        UIApplication.shared.openURL(URL(string: (mission.url))!)
    }
}
