//
//  SubmitInformationViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/8/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import SwiftValidator
import MRProgress

class SubmitInformationViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var numberError: UILabel!
    
    @IBOutlet weak var dialogView: UIView!
    // MARK: Properties
    var communityGroupsStorageManager: MapLocalStorageManager!
    var comGroup: CommunityGroup!
    let validator = Validator()
    
    fileprivate let fullNameKey = "fullName"
    fileprivate let phoneNoKey = "phoneNumber"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up storage managers for ministry teams and for storing/loading user information
        communityGroupsStorageManager = MapLocalStorageManager(key: Config.CommunityGroupsStorageKey)
        
        //set up validator to validate the fields
        validator.registerField(nameField, errorLabel: nameError, rules: [RequiredRule(), FullNameRule()])
        validator.registerField(numberField, errorLabel: numberError, rules: [RequiredRule(), CruPhoneNoRule()])
        nameError.text = ""
        numberError.text = ""
        
        //setup delegates for text fields
        nameField.delegate = self
        numberField.delegate = self
        
        //check if user is already in local storage
        
        
    }
    
    //Fill in fields after they've appeared
    override func viewDidAppear(_ animated: Bool) {
        /*if let user = communityGroupsStorageManager.getObject(Config.userStorageKey) as? NSDictionary {
            print(user)
            nameField.text = (user[fullNameKey] as? String)
            numberField.text = (user[phoneNoKey] as? String)
        }*/
    }

    @IBAction func closePopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Button Actions
    
    @IBAction func submitPressed(_ sender: UIButton) {
        validator.validate(self)
    }
    
    //function to call if the validation is successful
    func validationSuccessful() {
        
        var user: Dictionary<String, String>! = [:]
        
        user[fullNameKey] = nameField.text
        user[phoneNoKey] = numberField.text
        
        //update the user information in the local storage
        updateUserInformation(user as NSDictionary)
        
        //print("YO VALIDATION SUCCESSFUL BUT WAIT THERE'S MORE")
        showActivityIndicator()
        
        //join community group
        CruClients.getServerClient().joinCommunityGroup(comGroup.id, fullName: user[fullNameKey]!, phone: user[phoneNoKey]!, callback: completeJoinGroup)
        
        //CruClients.getServerClient().joinMinistryTeam(ministryTeam.id, fullName: user[fullNameKey]!, phone: user[phoneNoKey]!, callback: completeJoinTeam)
    }
    
    //Helper function to hide all the fields and show the progress indicator 
    private func showActivityIndicator() {
        nameField.isHidden = true
        numberField.isHidden = true
        nameError.isHidden = true
        numberError.isHidden = true
        
        MRProgressOverlayView.showOverlayAdded(to: self.dialogView, animated: true)
    }
    
    //Complete joining a community group by storing it in local storage
    func completeJoinGroup(_ leaderInfo: NSArray?) {
        let storeGroup = StoredCommunityGroup(group: comGroup, role: "member")
        var comGroupArray = [StoredCommunityGroup]()
        
        // Add new group to previously joined groups in local storage
        guard let prevGroupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let prevGroupArray = NSKeyedUnarchiver.unarchiveObject(with: prevGroupData as Data) as? [StoredCommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        for group in prevGroupArray {
            print("")
            print("group.id: \(group.id)")
            print("group.desc: \(group.desc)")
            print("place.parentMinistry: \(group.parentMinistryName)")
            comGroupArray.append(group)
        }
        
        comGroupArray.append(storeGroup)
        
        
        
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: comGroupArray)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)
        
        
        MRProgressOverlayView.dismissOverlay(for: self.dialogView, animated: true)
        
        //navigate back to get involved
        dismissToGetInvolved()
    }
    
    public func loadCommunityGroups() {
        
        
    }
    
    func dismissToGetInvolved() {
        let nav = self.presentingViewController as! UINavigationController
        dismiss(animated: true, completion: { () -> Void in
            nav.popViewController(animated: true)
        })
    }
    
    //used to update the user's information on the sign up page
    func updateUserInformation(_ user: NSDictionary) {
        let storedUser = communityGroupsStorageManager.getObject(Config.userStorageKey)
        
        //if there is no information stored about the user yet
        if storedUser == nil {
            //            print("ADDED NEW USER")
            communityGroupsStorageManager.putObject(Config.userStorageKey, object: user)
        }
            //if the information about the user is different in this form
        else {
            if let tempStore = storedUser as? NSDictionary {
                let storedFullName = tempStore[fullNameKey] as? String
                let storedPhoneNo = tempStore[phoneNoKey] as? String
                let fullName = user[fullNameKey] as? String
                let phoneNo = user[phoneNoKey] as? String
                
                if (storedFullName != fullName) || (storedPhoneNo != phoneNo) {
                    communityGroupsStorageManager.putObject(Config.userStorageKey, object: user)
                }
            }
        }
    }
    
    //function to call if the validation is not successful
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }
    
    //text field delegate method for parsing and formatting the phone number
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == nameField){
            return GlobalUtils.shouldChangeNameTextInRange(textField.text!, range: range, text: string)
        }
        else if textField == numberField {
            let res = GlobalUtils.shouldChangePhoneTextInRange(numberField.text!, range: range, replacementText: string)
            numberField.text = res.newText
            
            return res.shouldChange
        }
        
        return false
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
