//
//  CommunityGroupCell.swift
//  Cru
//
//  Created by Peter Godkin on 5/25/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class CommunityGroupCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var descript: UITextView!
    
    @IBOutlet weak var meetingTime: UILabel!
    private var group: CommunityGroup!
    
    private var signupCallback: (Void->Void)!
    
    func setGroup(group: CommunityGroup) {
        self.group = group
        name.text = group.name
        descript.text = group.description
        meetingTime.text = group.getMeetingTime()
    }

    @IBAction func signUpPressed(sender: AnyObject) {
        GlobalUtils.saveString(Config.communityGroupKey, value: group.id)
        signupCallback()
    }
    
    func setSignupCallback(callback: Void -> Void) {
        signupCallback = callback
    }
}
