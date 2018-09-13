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
    case loginLogout
}

class ProfileVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let tableViewLayout: [ProfileTableViewCellType] = [.email, .notifications, .chooseMovements, .loginLogout]
    let profileHeaderView = UINib(nibName: "ProfileHeaderView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ProfileHeaderView
    private var shadowImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerCell(ProfileEmailCell.self)
        self.tableView.registerCell(ProfileNotificationsCell.self)
        self.tableView.registerCell(ProfileSelectableTextCell.self)
        
        // get rid of lines below the cells
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.shadowImageView?.isHidden = false
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = self.findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    
    @IBAction func didPressCloseButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewLayout.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch self.tableViewLayout[indexPath.row] {
        case .email:
            cell = tableView.dequeueCell(ProfileEmailCell.self, indexPath: indexPath)
        case .notifications:
            cell = tableView.dequeueCell(ProfileNotificationsCell.self, indexPath: indexPath)
        case .chooseMovements:
            cell = tableView.dequeueCell(ProfileSelectableTextCell.self, indexPath: indexPath)
            if let cell = cell as? ProfileSelectableTextCell {
                cell.viewModel = ProfileSelectableTextCell.ViewModel(text: "Choose Movement")
            }
        case .loginLogout:
            cell = tableView.dequeueCell(ProfileSelectableTextCell.self, indexPath: indexPath)
            let userIsLoggedIn = LoginManager.instance.user != nil
            if let loginLogoutCell = cell as? ProfileSelectableTextCell {
                loginLogoutCell.viewModel = ProfileSelectableTextCell.ViewModel(text: userIsLoggedIn ? "Logout" : "Login")
            }
        }
        return cell
    }
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.profileHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.profileHeaderView.frame.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.tableViewLayout[indexPath.row] {
        case .notifications:
            self.show(NotificationsVC(), sender: self)
        case .chooseMovements:
            let vc = ChooseCampusVC()
            vc.title = "Choose Campus"
            let navVC = UINavigationController(rootViewController: vc)
            self.present(navVC, animated: true, completion: nil)
            break
        case .loginLogout:
            break
        default:
            return
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
}
