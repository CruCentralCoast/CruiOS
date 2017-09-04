//
//  CommunityGroupNoImageCell.swift
//  Cru
//
//  Created by Erica Solum on 8/17/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupNoImageCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!
    @IBOutlet weak var ministryLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    fileprivate var signupCallback: ((Void)->Void)!
    
    @IBOutlet weak var joinButton: UIButton!
    var groupID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    @IBAction func signUpPressed(_ sender: AnyObject) {
        GlobalUtils.saveString(Config.communityGroupKey, value: groupID)
        signupCallback()
    }
    
    
    
    func setSignupCallback(_ callback: @escaping (Void) -> Void) {
        signupCallback = callback
    }

}
