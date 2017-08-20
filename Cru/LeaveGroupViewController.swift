//
//  LeaveGroupViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/7/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class LeaveGroupViewController: UIViewController{
    @IBOutlet weak var dialogView: UIView!
    var group: CommunityGroup!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Actions
    
    @IBAction func leaveGroup(_ sender: UIButton) {
        
        //CruClients.getServerClient().joinCommunityGroup(comGroup.id, fullName: user[fullNameKey]!, phone: user[phoneNoKey]!, callback: completeJoinGroup)
        //As soon as server endpoint is created, pass completeLeaveGroup as callback like above
        
        completeLeaveGroup()
        
        
    }
    @IBAction func closeDialog(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //Complete joining a community group by storing it in local storage
    func completeLeaveGroup() {
        
        var comGroupArray = [CommunityGroup]()
        
        // Add new group to previously joined groups in local storage
        // Add new group to previously joined groups in local storage
        if let prevGroupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData {
            if let prevGroupArray = NSKeyedUnarchiver.unarchiveObject(with: prevGroupData as Data) as? [CommunityGroup] {
                
                for cGroup in prevGroupArray {
                    
                    if cGroup.id != group.id {
                        comGroupArray.append(cGroup)
                        print("HERE WE GO")
                    }
                    
                }
            }
            else {
                print("Could not unarchive from groupData")
            }
        }
        else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            
        }
        
        /*guard let prevGroupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let prevGroupArray = NSKeyedUnarchiver.unarchiveObject(with: prevGroupData as Data) as? [CommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }*/
        
        
        
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: comGroupArray)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)
        
        
        MRProgressOverlayView.dismissOverlay(for: self.dialogView, animated: true)
        
        //navigate back to get involved
        dismissToGetInvolved()
    }
    
    func dismissToGetInvolved() {
        let nav = self.presentingViewController as! UINavigationController
        dismiss(animated: true, completion: { () -> Void in
            nav.popViewController(animated: true)
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
