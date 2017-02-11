

import UIKit

class LogoutViewController: UIViewController {


    @IBOutlet weak var loggedInLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    override func viewDidLoad() {
        usernameLabel.text = GlobalUtils.loadString(Config.username)
        //loggedInLabel.text = "You are alredy logged in as " + GlobalUtils.loadString(Config.username)
        
        navigationItem.title = "Log Out"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    
    
    @IBAction func logoutPressed(_ sender: AnyObject) {
        LoginUtils.logout()
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
}
