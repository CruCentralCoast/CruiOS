


import UIKit
import SwiftValidator
import MRProgress

class LoginViewController: UIViewController, ValidationDelegate, UITextFieldDelegate {
    /*@IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var usernameError: UILabel!
    
    @IBOutlet weak var passwordError: UILabel!*/
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordError: UILabel!
    @IBOutlet weak var passwordLine: UIView!
    
    
    let validator = Validator()
    var groups = [CommunityGroup]()
    var savedGroups = [CommunityGroup]()
    
    override func viewDidLoad() {
        emailField.delegate = self
        emailField.returnKeyType = .next
        passwordField.delegate = self
        passwordField.returnKeyType = .done
        
        emailError.text = ""
        passwordError.text = ""
        
        emailField.text = GlobalUtils.loadString(Config.email)
        
        
        validator.registerField(emailField, errorLabel: emailError, rules: [RequiredRule(), EmailRule()])
        validator.registerField(passwordField, errorLabel: passwordError, rules: [RequiredRule()])
        
        navigationItem.title = "Log In"
        
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    func validationSuccessful() {
        let username = emailField.text
        let password = passwordField.text
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        LoginUtils.login(username!, password: password!, completionHandler : {(success : Bool) in
            
            let title = success ? "Login Successful" : "Login Failed"
            
            let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alertAction) in
                if (success) {
                    if let navController = self.navigationController {
                        navController.popViewController(animated: true)
                    }
                }
            }))
            
            if success {
                self.loadCommunityGroups()
                LoginUtils.getUserInfo(insert: self.insertUserInfo, afterFunc: self.completeGetUserInfo)
                
            }
            
            
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true, completion: {
                self.present(alert, animated: true, completion: nil)
                
            })
        })
    }
    
    func insertUserInfo(_ dict: NSDictionary) {
        if let email = dict[UserKeys.email] as? String {
            GlobalUtils.saveString(Config.email, value: email)
        }
        if let phone = dict[UserKeys.phone] as? String {
            GlobalUtils.saveString(Config.phone, value: phone)
        }
        if let leader = dict[UserKeys.isCommunityGroupLeader] as? Bool {
            GlobalUtils.saveBool(UserKeys.isCommunityGroupLeader, value: leader)
        }
        if let notifications = dict[UserKeys.notifications] as? NSDictionary {
            if let groupNotifications = notifications[UserKeys.communityGroupUpdates] as? Bool{
                GlobalUtils.saveBool(UserKeys.communityGroupUpdates, value: groupNotifications)
            }
            if let teamNotifications = notifications[UserKeys.ministryTeamUpdates] as? Bool{
                GlobalUtils.saveBool(UserKeys.ministryTeamUpdates, value: teamNotifications)
            }
        }
    }
    
    func completeGetUserInfo(_ success: Bool) {
        //Load community groups and check if they're a leader in any of them
        CruClients.getCommunityGroupUtils().loadGroups(insertGroup, completionHandler: finishInserting)
        
        // Send the FCM token to the server
        NotificationManager.shared.saveFCMToken(CruClients.getSubscriptionManager().loadFCMToken())
    }
    
    fileprivate func insertGroup(_ dict: NSDictionary) {
        //Create group and assign its parent ministry name
        let group = CommunityGroup(dict: dict)
        self.groups.insert(group, at: 0)
        
        // Load the leaders for the Community Group
        CruClients.getCommunityGroupUtils().loadLeaders({ leaderDict in
            let leader = CommunityGroupLeader(leaderDict)
            group.leaders.append(leader)
        }, parentId: group.id, completionHandler: { success in
            if success {
                print("Successfully loaded a leader!")
                self.saveCommunityGroups()
            } else {
                print("Nope, try loading the leader again.")
            }
        })
    }
    
    //helper function for finishing off inserting group data
    fileprivate func finishInserting(_ success: Bool) {
        let userID = GlobalUtils.loadString(Config.userID)
        let filteredGroups = [CommunityGroup]()
        var ministryTable = CruClients.getCommunityGroupUtils().getMinistryTable()
        
        for group in groups {
            if group.leaderIDs.contains(userID) {
                group.role = "leader"
                if let parentMin = ministryTable[group.parentMinistryID] {
                    group.parentMinistryName = parentMin
                }
                savedGroups.append(group)
            }
        }
        saveCommunityGroups()
        
    }
    
    func saveCommunityGroups() {
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: savedGroups)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)
    }
    
    public func loadCommunityGroups() {
        guard let groupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let groupArray = NSKeyedUnarchiver.unarchiveObject(with: groupData as Data) as? [CommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        savedGroups = groupArray
        
    }
    
    func resetLabel(_ field: UITextField, error: UILabel){
        field.layer.borderColor = UIColor.clear.cgColor
        field.layer.borderWidth = 0.0
        error.text = ""
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        
        var userValid = true
        var pwdValid = true
        
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                //field.layer.borderColor = CruColors.yellow.cgColor
                //field.layer.borderWidth = 1.0
                
                if(field == emailField){
                    userValid = false
                }
                if(field == passwordField){
                    pwdValid = false
                }
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
            
            
        }
        
        if(userValid){
            resetLabel(emailField, error: emailError)
        }
        if(pwdValid){
            resetLabel(passwordField, error: passwordError)
        }
    }
    
    @IBAction func loginPressed() {
        validator.validate(self)
    }
    
    // MARK: - Text Field delegate stuff
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailField!:
            makeFieldInactive(emailLine, field: emailField)
        case passwordField!:
            makeFieldInactive(passwordLine, field: passwordField)
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case emailField!:
            highlightField(emailLine, field: emailField)
        case passwordField!:
            highlightField(passwordLine, field: passwordField)
        default:
            print("Text field not recognized")
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField!:
            self.passwordField.becomeFirstResponder()
        case passwordField!:
            self.passwordField.resignFirstResponder()
            self.loginPressed()
        default:
            print("Text field not recognized")
        }
        return true
    }
    
    // MARK: Animations
    func highlightField(_ view: UIView, field: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = CruColors.lightBlue
            field.textColor = CruColors.lightBlue
            
        })
    }
    
    func makeFieldInactive(_ view: UIView, field: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            view.backgroundColor = Colors.lightInactiveGray
            field.textColor = UIColor.white
        })
    }
}
