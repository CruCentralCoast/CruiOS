//
//  CommunityGroupDetailsViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/7/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import AlamofireImage

class CommunityGroupDetailsViewController: UIViewController {
    var group: CommunityGroup!

    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ministryLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var groupActionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if group != nil {
            descriptionView.text = group.desc
            leaderLabel.text = group.getLeaderString()
            typeLabel.text = group.getTypeString()
            ministryLabel.text  = group.parentMinistryName
            timeLabel.text = group.getMeetingTime()
            if group.imgURL != "" {
                //Load image or get from cache
                let urlRequest = URLRequest(url: URL(string: group.imgURL)!)
                CruClients.getImageUtils().getImageDownloader().download(urlRequest) { response in
                    if let image = response.result.value {
                        self.imageView.image = image
                    }
                }
                
            }
        }
        //Removes the extra text from the back button
        self.navigationController?.navigationBar.backItem?.title = " "



        //Assign the action of the bottom button depending on if user is leader
        if group.leaderIDs.contains(GlobalUtils.loadString(Config.userID)) {
            // Change the group action button from "Leave Group" to "Edit Group"
            groupActionButton.setTitle("Edit Group", for: .normal)
            groupActionButton.backgroundColor = CruColors.orange
            groupActionButton.addTarget(self, action: #selector(self.editGroup), for: .touchUpInside)
        }
        else {
            groupActionButton.addTarget(self, action: #selector(self.leaveGroup), for: .touchUpInside)
        }
        
    }
    
    func editGroup() {
        let storyboard = UIStoryboard(name: "communitygroups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "editVC") as! EditGroupInfoViewController
        controller.group = group
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func leaveGroup() {
        let storyboard = UIStoryboard(name: "communitygroups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "leaveDialog") as! LeaveGroupViewController
        controller.group = self.group
        controller.modalPresentationStyle = .currentContext
        controller.modalTransitionStyle = .crossDissolve
        self.present(controller, animated: true, completion: nil)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        /*if segue.identifier == "leaveDialogeSegue" {
            let vc = segue.destination as! LeaveGroupViewController
            vc.group = self.group
        }*/
    }
 

}
