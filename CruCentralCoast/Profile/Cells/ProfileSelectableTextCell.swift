//
//  ProfileLoginLogoutCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ProfileSelectableTextCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    
    struct ViewModel {
        let text: String
        
        static let empty: ViewModel = ViewModel(text: "")
    }
    
    var viewModel: ViewModel = .empty {
        didSet {
            self.titleLabel.text = self.viewModel.text
        }
    }
    
    
}
