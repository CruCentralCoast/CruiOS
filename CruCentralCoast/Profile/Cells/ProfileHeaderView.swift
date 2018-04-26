//
//  ProfileHeaderView.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfileHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fakeBottomOfNavBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.fakeBottomOfNavBar.addBorders(edges: .bottom, color: .navBarLineGray, thickness: 0.5)
    }
    
    
    
}
