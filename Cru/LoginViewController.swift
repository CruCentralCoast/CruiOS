


import UIKit
import SwiftValidator
import MRProgress

class LoginViewController: UIViewController, ValidationDelegate {
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var usernameError: UILabel!
    
    @IBOutlet weak var passwordError: UILabel!
    
    let validator = Validator()
    
    override func viewDidLoad() {
        usernameError.text = ""
        passwordError.text = ""
        
        usernameField.text = GlobalUtils.loadString(Config.username)
        
        validator.registerField(usernameField, errorLabel: usernameError, rules: [RequiredRule(), EmailRule()])
        validator.registerField(passwordField, errorLabel: passwordError, rules: [RequiredRule()])
        
        navigationItem.title = "Log In"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    func validationSuccessful() {
        let username = usernameField.text
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
            
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true, completion: {
                self.present(alert, animated: true, completion: nil)
                
            })
        })
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
                field.layer.borderColor = CruColors.yellow.cgColor
                field.layer.borderWidth = 1.0
                
                if(field == usernameField){
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
            resetLabel(usernameField, error: usernameError)
        }
        if(pwdValid){
            resetLabel(passwordField, error: passwordError)
        }
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        validator.validate(self)
    }
}
