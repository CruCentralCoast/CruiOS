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
}

class ProfileVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let tableViewLayout: [ProfileTableViewCellType] = [.email, .notifications]
    let profileHeaderView = UINib(nibName: "ProfileHeaderView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! ProfileHeaderView
    private var shadowImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.registerCell(ProfileEmailCell.self)
        self.tableView.registerCell(ProfileNotificationsCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shadowImageView == nil {
            self.shadowImageView = self.findShadowImage(under: self.navigationController!.navigationBar)
        }
        self.shadowImageView?.isHidden = true
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
    
}

extension ProfileVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableViewLayout.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let type = self.tableViewLayout[indexPath.row]
        switch type {
        case .email:
            cell = tableView.dequeueCell(ProfileEmailCell.self, indexPath: indexPath)
        case .notifications:
            cell = tableView.dequeueCell(ProfileNotificationsCell.self, indexPath: indexPath)
        }
        return cell
    }
}

extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = self.tableViewLayout[indexPath.row]
        
        switch type {
        case .email:
            return 44
        case .notifications:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.profileHeaderView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // this should be the exact height of the "ProfileHeaderView"
        return 172
    }
    
}
