//
//  CampusCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 7/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CampusCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var campusImageView: UIImageView!
    @IBOutlet weak var movementsLabel: UILabel!
    
    private var currentImageLink: String?

    func configure(with campus: Campus, subscribedMovements: [String]) {
        if campus.movements.count > 1 {
            self.accessoryType = .disclosureIndicator
            let filteredMovements = campus.movements.filter({ subscribedMovements.contains($0.id) })
            self.movementsLabel.text = filteredMovements.map({ $0.name }).joined(separator: ", ")
        } else {
            self.accessoryType = subscribedMovements.contains(campus.movements[0].id) ? .checkmark : .none
            self.movementsLabel.text = ""
        }
        self.titleLabel.text = campus.name
        // TODO: Remove "http:" when backend image links are fixed
        self.currentImageLink = (campus.imageLink == nil) ? nil : "http:\(campus.imageLink!)"
        if let imageLink = ((campus.imageLink == nil) ? nil : "http:\(campus.imageLink!)") {
            ImageManager.instance.fetch(imageLink) { [weak self] image in
                if let currentImageLink = self?.currentImageLink, currentImageLink == imageLink {
                    DispatchQueue.main.async {
                        self?.campusImageView.image = image
                    }
                }
            }
        }
    }
}
