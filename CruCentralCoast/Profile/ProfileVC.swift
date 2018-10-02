//
//  ProfileVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

enum ProfileTableViewCellType {
    case email
    case notifications
    case chooseMovements
    case termsOfService
    case privacyPolicy
    case loginLogout
}

class ProfileVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // TODO: Re-enable privacy policy cell when we have an updated privacy policy
    private let tableViewLayout: [[ProfileTableViewCellType]] = [[.email, .notifications, .chooseMovements], [.termsOfService/*, .privacyPolicy*/], [.loginLogout]]
    private let profileHeaderView = UINib(nibName: "ProfileHeaderView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ProfileHeaderView

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCell(ProfileEmailCell.self)
        self.tableView.registerCell(ProfileNotificationsCell.self)
        self.tableView.registerCell(ProfileSelectableTextCell.self)
        self.tableView.registerCell(ProfileDetailCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    @IBAction func didPressCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ProfileVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableViewLayout.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewLayout[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.tableViewLayout[indexPath.section][indexPath.row] {
        case .email:
            cell = tableView.dequeueCell(ProfileEmailCell.self, indexPath: indexPath)
            (cell as! ProfileEmailCell).configure(with: LoginManager.instance.user)
        case .notifications:
            cell = tableView.dequeueCell(ProfileNotificationsCell.self, indexPath: indexPath)
            // TODO (Issue #187): Change this value when push notifications are properly implemented
            (cell as! ProfileNotificationsCell).configure(with: 0)
        case .chooseMovements:
            cell = tableView.dequeueCell(ProfileSelectableTextCell.self, indexPath: indexPath)
            (cell as! ProfileSelectableTextCell).configure(with: "Change Campus")
        case .termsOfService:
            cell = tableView.dequeueCell(ProfileDetailCell.self, indexPath: indexPath)
            (cell as! ProfileDetailCell).configure(with: "Terms of Service")
        case .privacyPolicy:
            cell = tableView.dequeueCell(ProfileDetailCell.self, indexPath: indexPath)
            (cell as! ProfileDetailCell).configure(with: "Privacy Policy")
        case .loginLogout:
            cell = tableView.dequeueCell(ProfileSelectableTextCell.self, indexPath: indexPath)
            let userIsLoggedIn = LoginManager.instance.user != nil
            (cell as! ProfileSelectableTextCell).configure(with: userIsLoggedIn ? "Logout" : "Login")
        }
        return cell
    }
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            self.profileHeaderView.configure(with: LoginManager.instance.user)
            return self.profileHeaderView
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.profileHeaderView.frame.height
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.tableViewLayout[indexPath.section][indexPath.row] {
        case .notifications:
            let vc = NotificationsVC()
            self.show(vc, sender: self)
        case .chooseMovements:
            let vc = ChooseCampusVC()
            let nav = UINavigationController(rootViewController: vc)
            self.show(nav, sender: self)
        case .termsOfService:
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(ProfileTermsOfServiceVC.self)
            self.show(vc, sender: self)
        case .privacyPolicy:
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(ProfilePrivacyPolicyVC.self)
            self.show(vc, sender: self)
        case .loginLogout:
            let userIsLoggedIn = LoginManager.instance.user != nil
            if userIsLoggedIn {
                LoginManager.instance.logout(sender: self)
                self.tableView.reloadData()
            } else {
                LoginManager.instance.presentLogin(from: self)
            }
        default:
            return
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}
