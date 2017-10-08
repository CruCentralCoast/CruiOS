//
//  SignUpViewController.swift
//  Cru
//
//  Created by Tyler Dahl on 7/9/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import AnimatedTextInput
import SwiftValidator

class MinistryTeamSignUpViewController: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var fullNameTextInput: AnimatedTextInput!
    @IBOutlet weak var phoneNumberTextInput: AnimatedTextInput!
    
    fileprivate let fullNameKey = "fullName"
    fileprivate let phoneNumberKey = "phoneNo"
    
    fileprivate var ministryTeamStorageManager: MapLocalStorageManager<MinistryTeam>!
    fileprivate var localStorageManager: LocalStorageManager!
    private var validator: Validator!
    
    var delegate: MinistryTeamSignUpDelegate?
    
    var ministryTeam: MinistryTeam!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cardView.layer.cornerRadius = 7
        
        // Configure text inputs
        self.fullNameTextInput.placeHolderText = "Full Name"
        self.fullNameTextInput.style = CustomTextInputStyle()
        self.fullNameTextInput.delegate = self
        
        self.phoneNumberTextInput.placeHolderText = "Phone Number"
        self.phoneNumberTextInput.style = CustomTextInputStyle()
        self.phoneNumberTextInput.type = .numeric
        self.phoneNumberTextInput.delegate = self
        
        // Create validator to validate text input fields upon submission
        self.validator = Validator()
        self.validator.registerField(self.fullNameTextInput, errorLabel: nil, rules: [RequiredRule(), FullNameRule()])
        self.validator.registerField(self.phoneNumberTextInput, errorLabel: nil, rules: [RequiredRule(), CruPhoneNoRule()])
        
        // Setup local storage for ministry teams
        self.ministryTeamStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        self.localStorageManager = LocalStorageManager()
        
        // Populate text inputs with user info
        if let user = self.localStorageManager.object(forKey: Config.userStorageKey) as? NSDictionary {
            self.fullNameTextInput.text = user[self.fullNameKey] as? String ?? ""
            self.phoneNumberTextInput.text = user[self.phoneNumberKey] as? String ?? ""
        }
        
        // Dismiss keyboard when tapping view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func closePressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPressed() {
        self.fullNameTextInput.resignFirstResponder()
        self.phoneNumberTextInput.resignFirstResponder()
        self.validator.validate(self)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

extension MinistryTeamSignUpViewController: AnimatedTextInputDelegate {
    func animatedTextInput(animatedTextInput: AnimatedTextInput, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if animatedTextInput == self.fullNameTextInput {
            return GlobalUtils.shouldChangeNameTextInRange(self.fullNameTextInput.text!, range: range, text: string)
        } else if animatedTextInput == self.phoneNumberTextInput {
            let result = GlobalUtils.shouldChangePhoneTextInRange(self.phoneNumberTextInput.text!, range: range, replacementText: string)
            self.phoneNumberTextInput.text = result.newText
            
            return result.shouldChange
        }
        
        return false
    }
    
    func animatedTextInputShouldReturn(animatedTextInput: AnimatedTextInput) -> Bool {
        animatedTextInput.resignFirstResponder()
        return false
    }
}

extension MinistryTeamSignUpViewController: ValidationDelegate {
    func validationSuccessful() {
        var user = [String:String]()
        user[self.fullNameKey] = self.fullNameTextInput.text
        user[self.phoneNumberKey] = self.phoneNumberTextInput.text
        
        // Update the user information in local storage
        self.updateUserInformation(user as NSDictionary)
        
        // Join the ministry team
        CruClients.getServerClient().joinMinistryTeam(self.ministryTeam.id, fullName: user[self.fullNameKey]!, phone: user[self.phoneNumberKey]!, callback: self.completeJoinTeam)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        for (field, error) in errors {
            if let field = field as? AnimatedTextInput {
                field.show(error: error.errorMessage)
            }
        }
    }
    
    func completeJoinTeam(_ leaderInfo: NSArray?) {
        // Save ministry team in local storage
        self.ministryTeamStorageManager.save(self.ministryTeam, forKey: self.ministryTeam.id)
        
        self.dismiss(animated: true) {
            self.delegate?.didSignUpForMinistryTeam(self.ministryTeam)
        }
    }
    
    func updateUserInformation(_ user: NSDictionary) {
        let storedUser = self.localStorageManager.object(forKey: Config.userStorageKey)
        
        // Save user info if it's not already stored or if the info changed
        if storedUser == nil {
            self.localStorageManager.set(user, forKey: Config.userStorageKey)
        } else {
            if let tempStore = storedUser as? NSDictionary {
                let storedFullName = tempStore[self.fullNameKey] as? String ?? ""
                let storedPhoneNumber = tempStore[self.phoneNumberKey] as? String ?? ""
                let fullName = user[self.fullNameKey] as? String ?? ""
                let phoneNumber = user[self.phoneNumberKey] as? String ?? ""
                
                if (storedFullName != fullName) || (storedPhoneNumber != phoneNumber) {
                    self.localStorageManager.set(user, forKey: Config.userStorageKey)
                }
            }
        }
    }
}

extension AnimatedTextInput: Validatable {
    public var validationText: String {
        return self.text ?? ""
    }
}

struct CustomTextInputStyle: AnimatedTextInputStyle {
    //public var textInputFont: UIFont


    let activeColor = CruColors.lightBlue
    let inactiveColor = CruColors.gray
    let lineInactiveColor = CruColors.gray
    let errorColor = UIColor.red
    let textInputFont = Config.regularFont18!
    let textInputFontColor = UIColor.black
    let placeholderMinFontSize: CGFloat = 9
    let counterLabelFont: UIFont? = Config.regularFont16
    let leftMargin: CGFloat = 8
    let topMargin: CGFloat = 20
    let rightMargin: CGFloat = 0
    let bottomMargin: CGFloat = 4
    let yHintPositionOffset: CGFloat = 7
    let yPlaceholderPositionOffset: CGFloat = 0
    public let textAttributes: [String: Any]? = nil
}

