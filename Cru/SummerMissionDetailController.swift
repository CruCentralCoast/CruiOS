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
    
    //MARK: Properties
    
    @IBOutlet private weak var image: UIImageView!
    //@IBOutlet private weak var topCoverView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var datesLabel: UILabel!
    //@IBOutlet private weak var scrollingView: UIView!
    @IBOutlet private weak var descriptionView: UITextView!
    @IBOutlet private weak var locationLabel: UILabel!
    
    //@IBOutlet private weak var fbButton: UIButton!
    //@IBOutlet private weak var eventTimeLabel: UILabel!
    
    @IBOutlet weak var learnMoreButton: UIButton!
    
    private let COVER_ALPHA: CGFloat = 0.35
    var uiImage: UIImage!
    var mission: SummerMission!
    var dateText = ""
    //MARK: Actions
    
    @IBAction func learnMoreButton(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: (mission.url))!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        image.image = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
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
        }
        
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = uiImage
    }
    

}
