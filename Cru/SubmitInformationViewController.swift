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
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameLine: UIView!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var numberLine: UIView!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var numberError: UILabel!
    
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    // MARK: Properties
    var localStorageManager: LocalStorageManager!
    var comGroup: CommunityGroup!
    let validator = Validator()
    var buttonState = 0
    
    fileprivate let fullNameKey = "fullName"
    fileprivate let phoneNoKey = "phoneNumber"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up storage managers for ministry teams and for storing/loading user information
        self.localStorageManager = LocalStorageManager()
        
        //set up validator to validate the fields
        validator.registerField(nameField, errorLabel: nameError, rules: [RequiredRule(), FullNameRule()])
        validator.registerField(numberField, errorLabel: numberError, rules: [RequiredRule(), CruPhoneNoRule()])
        nameError.text = ""
        numberError.text = ""
        
        //setup delegates for text fields
        nameField.delegate = self
        numberField.delegate = self
        
        //check if user is already in local storage
        if let user = self.localStorageManager.object(forKey: Config.userStorageKey) as? NSDictionary {
            self.nameField.text = user[self.fullNameKey] as? String ?? ""
            self.numberField.text = user[self.phoneNoKey] as? String ?? ""
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case nameField!:
            makeFieldInactive(nameLine)
        //nameLine?.backgroundColor = inactiveGray
        case numberField:
            makeFieldInactive(numberLine)
            numberField!.text = PhoneFormatter.unparsePhoneNumber(numberField!.text!)
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameField!:
            highlightField(nameLine)
        case numberField!:
            highlightField(numberLine)
        default:
            print("Text field not recognized")
        }
    }
    
    // MARK: Animations
    func highlightField(_ view: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = CruColors.lightBlue
        })
    }
    
    func makeFieldInactive(_ view: UIView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = Colors.inactiveGray
        })
    }

    @IBAction func closePopup(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Button Actions
    
    @IBAction func submitPressed(_ sender: UIButton) {
        //increase button state
        buttonState += 1
        if buttonState == 1 {
            validator.validate(self)
        }
        else {
            dismissToGetInvolved()
        }
        
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

    }
    
    //Helper function to hide all the fields and show the progress indicator 
    private func showActivityIndicator() {
        nameField.isHidden = true
        nameLine.isHidden = true
        nameError.isHidden = true
        numberField.isHidden = true
        numberLabel.isHidden = true
        numberError.isHidden = true
        nameLabel.isHidden = true
        numberLine.isHidden = true
        
        MRProgressOverlayView.showOverlayAdded(to: self.dialogView, animated: true)
    }
    
    //Complete joining a community group by storing it in local storage
    func completeJoinGroup(_ leaderInfo: NSArray?) {
        var comGroupArray = [CommunityGroup]()
        comGroup.role = "member"
        
        // Add new group to previously joined groups in local storage
        if let prevGroupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData {
            if let prevGroupArray = NSKeyedUnarchiver.unarchiveObject(with: prevGroupData as Data) as? [CommunityGroup] {
                for group in prevGroupArray {
                    comGroupArray.append(group)
                }
            }
            else {
                print("Could not unarchive from groupData")
            }
        }
        else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")

        }
        
        comGroupArray.append(comGroup)
        
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: comGroupArray)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)
        
        MRProgressOverlayView.dismissOverlay(for: self.dialogView, animated: true)
        
        
        /*dismiss(animated: true, completion: { () -> Void in
            let storyboard = UIStoryboard(name: "communitygroups", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "confirmDialog") as! ConfirmJoinGroupViewController
            
            self.present(controller, animated: true, completion: nil)
        })*/
        
        
        
        // Hide all other views and show confirmation message
        
        let confirmLabel = UILabel()
        confirmLabel.text = "Your community group leaders will contact you soon with more information."
        confirmLabel.textColor = UIColor.black
        confirmLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmLabel.font = UIFont(name: Config.fontName, size: 18)
        dialogView.addSubview(confirmLabel)
        confirmLabel.numberOfLines = 0
        
        let leading = NSLayoutConstraint(item: confirmLabel, attribute: .left, relatedBy: .equal, toItem: dialogView, attribute: .left, multiplier: 1.0, constant: 15.0)
        let trailing = NSLayoutConstraint(item: confirmLabel, attribute: .right, relatedBy: .equal, toItem: dialogView, attribute: .right, multiplier: 1.0, constant: 15.0)
        let top = NSLayoutConstraint(item: confirmLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1.0, constant: 18.0)
        let bottom = NSLayoutConstraint(item: confirmLabel, attribute: .bottom, relatedBy: .equal, toItem: submitButton, attribute: .top, multiplier: 1.0, constant: 18.0)
        dialogView.addConstraints([leading, trailing, top, bottom])
        
        
        submitButton.setTitle("Great", for: .normal)
        
        
    }
    
    func confirmationPressed(_ sender: UIButton) {
        //navigate back to get involved
        dismissToGetInvolved()
    }
    
    func dismissToGetInvolved() {
        let nav = self.presentingViewController as! UINavigationController
        dismiss(animated: true, completion: { () -> Void in
            nav.popViewController(animated: true)
        })
    }
    
    //used to update the user's information on the sign up page
    func updateUserInformation(_ user: NSDictionary) {
        let storedUser = self.localStorageManager.object(forKey: Config.userStorageKey)
        
        if storedUser == nil {
            self.localStorageManager.set(user, forKey: Config.userStorageKey)
        } else {
            if let tempStore = storedUser as? NSDictionary {
                let storedFullName = tempStore[fullNameKey] as? String
                let storedPhoneNo = tempStore[phoneNoKey] as? String
                let fullName = user[fullNameKey] as? String
                let phoneNo = user[phoneNoKey] as? String
                
                if (storedFullName != fullName) || (storedPhoneNo != phoneNo) {
                    self.localStorageManager.set(user, forKey: Config.userStorageKey)
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
