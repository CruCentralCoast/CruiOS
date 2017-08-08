//
//  CommunityGroupDetailsViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/7/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupDetailsViewController: UIViewController {
    var group: StoredCommunityGroup!

    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ministryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if group != nil {
            print("KJSHADF;AHJSDF;")
            descriptionView.text = group.desc
            leaderLabel.text = group.getLeaderString()
            typeLabel.text = "Type goes here"
            timeLabel.text = group.stringTime
            if group.imgURL != "" {
                imageView.load.request(with: group.imgURL)
            }
        }
        
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        if segue.identifier == "leaveDialogeSegue" {
            let vc = segue.destination as! LeaveGroupViewController
            vc.group = self.group
        }
    }
 

}
