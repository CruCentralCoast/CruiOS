//
//  CommunityGroupDetailsViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/7/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupDetailsViewController: UIViewController {
    var group: CommunityGroup!

    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ministryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if group != nil {
            descriptionView.text = group.desc
            leaderLabel.text = group.getLeaderString()
            typeLabel.text = group.getTypeString()
            ministryLabel.text  = group.parentMinistryName
            timeLabel.text = group.getMeetingTime()
            if group.imgURL != "" {
                imageView.load.request(with: group.imgURL)
            }
        }
        
        //Add edit button if user is a community group leader
        if GlobalUtils.loadBool(UserKeys.isCommunityGroupLeader) {
            let editButton = UIButton(type: .custom)
            editButton.setImage(UIImage(named: "edit-icon"), for: .normal)
            editButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            editButton.addTarget(self, action: #selector(self.editGroup), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: editButton)
            
            self.navigationItem.setRightBarButton(item1, animated: true)
        }
    }
    
    func editGroup() {
        let storyboard = UIStoryboard(name: "communitygroups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "editVC") as! EditGroupInfoViewController
        controller.group = group
        self.navigationController?.pushViewController(controller, animated: true)
        
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
