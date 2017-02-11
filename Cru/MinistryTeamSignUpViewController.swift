//
//  MinistryTeamSignUpViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 5/19/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import SwiftValidator

class MinistryTeamSignUpViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    

    //reference to fields we will use
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var phoneNoField: UITextField!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var phoneNoError: UILabel!
    
    //constants: should move later to config file
    fileprivate let fullNameKey = "fullName"
    fileprivate let phoneNoKey = "phoneNo"

    var ministryTeamStorageManager: MapLocalStorageManager!
    var ministryTeam: MinistryTeam!
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up storage managers for ministry teams and for storing/loading user information
        ministryTeamStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        //set up validator to validate the fields
        validator.registerField(fullNameField, errorLabel: nameError, rules: [RequiredRule(), FullNameRule()])
        validator.registerField(phoneNoField, errorLabel: phoneNoError, rules: [RequiredRule(), CruPhoneNoRule()])
        nameError.text = ""
        phoneNoError.text = ""
        
        //setup delegates for text fields
        fullNameField.delegate = self
        phoneNoField.delegate = self
        
        //check if user is already in local storage
        if let user = ministryTeamStorageManager.getObject(Config.userStorageKey) as? NSDictionary {
            print(user)
            fullNameField.text = (user[fullNameKey] as! String)
            phoneNoField.text = (user[phoneNoKey] as! String)
        }
    }
    
    //action for submitting information from the sign up process
    @IBAction func submitInformation(_ sender: UIButton) {
        
        validator.validate(self)
    }
    
    //function to call if the validation is successful
    func validationSuccessful() {
        var user: Dictionary<String, String>! = [:]
        
        user[fullNameKey] = fullNameField.text
        user[phoneNoKey] = phoneNoField.text
        
        //update the user information in the local storage
        updateUserInformation(user as NSDictionary)
        
        //join ministry team
        CruClients.getServerClient().joinMinistryTeam(ministryTeam.id, fullName: user[fullNameKey]!, phone: user[phoneNoKey]!, callback: completeJoinTeam)
    }
    
    //completion handler for joining a ministry team
    func completeJoinTeam(_ leaderInfo: NSArray?) {
        //add ministry team to list of ministry teams we're a part of
        ministryTeamStorageManager.addElement(ministryTeam.id, elem: ministryTeam.ministryName)
        
        //navigate back to get involved
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKind(of: GetInvolvedViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    //used to update the user's information on the sign up page
    func updateUserInformation(_ user: NSDictionary) {
        let storedUser = ministryTeamStorageManager.getObject(Config.userStorageKey)
        
        //if there is no information stored about the user yet
        if storedUser == nil {
//            print("ADDED NEW USER")
            ministryTeamStorageManager.putObject(Config.userStorageKey, object: user)
        }
        //if the information about the user is different in this form
        else {
            if let tempStore = storedUser as? NSDictionary {
                let storedFullName = tempStore[fullNameKey] as! String
                let storedPhoneNo = tempStore[phoneNoKey] as! String
                let fullName = user[fullNameKey] as! String
                let phoneNo = user[phoneNoKey] as! String
                
                if (storedFullName != fullName) || (storedPhoneNo != phoneNo) {
//                    print("REPLACE EXISTING USER")
                    ministryTeamStorageManager.putObject(Config.userStorageKey, object: user)
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
        if(textField == fullNameField){
            return GlobalUtils.shouldChangeNameTextInRange(textField.text!, range: range, text: string)
        }
        else if textField == phoneNoField {
            let res = GlobalUtils.shouldChangePhoneTextInRange(phoneNoField.text!, range: range, replacementText: string)
            phoneNoField.text = res.newText
            
            return res.shouldChange
        }
        
        return false
    }

}
