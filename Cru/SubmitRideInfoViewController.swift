//
//  SubmitRideInfoViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/12/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress
import SwiftValidator

class SubmitRideInfoViewController: UIViewController, UITextFieldDelegate, ValidationDelegate {

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
    var activeField: UITextField?
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: Properties
    var localStorageManager: LocalStorageManager!
    let validator = Validator()
    var buttonState = 0
    var delegate: JoinRideDelegate?
    
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
        
        //Set up notifications for keyboard
        setupKeyboardNotifications()
        
        //check if user is already in local storage
        if let user = self.localStorageManager.object(forKey: Config.userStorageKey) as? NSDictionary {
            self.nameField.text = user[Config.fullNameKey] as? String ?? ""
            self.numberField.text = user[Config.phoneNoKey] as? String ?? ""
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterKeyboardNotifications()
    }
    // MARK: - Keyboard Notification Methods
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func deregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    // MARK: - Text Field delegate functions
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        switch textField {
        case nameField!:
            highlightField(nameLine)
        case numberField!:
            highlightField(numberLine)
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
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
    
    // MARK: - Button Actions
    
    @IBAction func submitPressed(_ sender: UIButton) {
        //increase button state
        if buttonState == 1 {
            //delegate?.didFinishTask(string: "Hello")
        }
        else {
            // Hide error labels in case of multiple validations
            nameError.isHidden = true
            numberError.isHidden = true
            
            validator.validate(self)
            
        }
        
    }
    
    //function to call if the validation is successful
    func validationSuccessful() {
        
        var user: Dictionary<String, String>! = [:]
        
        user[Config.fullNameKey] = nameField.text
        user[Config.phoneNoKey] = numberField.text
        
        //Change button state to Confirmation
        buttonState += 1
        
        //update the user information in the local storage
        updateUserInformation(user as NSDictionary)
        
        //print("YO VALIDATION SUCCESSFUL BUT WAIT THERE'S MORE")
        //showActivityIndicator()
        
        self.dismiss(animated: true, completion: nil)
        self.delegate?.didFinishTask(name: user[Config.fullNameKey]!, phone: user[Config.phoneNoKey]!)
        
        
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
    
    //used to update the user's information on the sign up page
    func updateUserInformation(_ user: NSDictionary) {
        let storedUser = self.localStorageManager.object(forKey: Config.userStorageKey)
        
        if storedUser == nil {
            self.localStorageManager.set(user, forKey: Config.userStorageKey)
        } else {
            if let tempStore = storedUser as? NSDictionary {
                let storedFullName = tempStore[Config.fullNameKey] as? String
                let storedPhoneNo = tempStore[Config.phoneNoKey] as? String
                let fullName = user[Config.fullNameKey] as? String
                let phoneNo = user[Config.phoneNoKey] as? String
                
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
                if field == nameField {
                    nameLine.backgroundColor = UIColor.red
                }
                else {
                    numberLine.backgroundColor = UIColor.red
                }
                //field.layer.borderColor = UIColor.red.cgColor
                //field.layer.borderWidth = 1.0
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
