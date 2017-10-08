//
//  SummerMissionsTableViewCell.swift
//  Cru
//
//  Created by Deniz Tumer on 5/13/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SummerMissionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var missionImage: UIImageView!
    @IBOutlet weak var missionName: UILabel!
    @IBOutlet weak var missionDateLabel: UILabel!
    @IBOutlet weak var missionLocation: UILabel!
    @IBOutlet weak var card: UIView!
    
    var mission: SummerMission! {
        didSet {
            let dateFormat = "MMM d, yyyy"
            let startDate = GlobalUtils.stringFromDate(self.mission.startNSDate, format: dateFormat)
            let endDate = GlobalUtils.stringFromDate(self.mission.endNSDate, format: dateFormat)
            let date = startDate + " - " + endDate
            
            if self.mission.imageLink != "" {
                let urlRequest = URLRequest(url: URL(string: self.mission.imageLink)!)
                CruClients.getImageUtils().getImageDownloader().download(urlRequest) { response in
                    if let image = response.result.value {
                        self.missionImage.image = image
                    }
                }
            } else {
                self.missionImage.image = nil
            }
            self.missionName.text = self.mission.name
            self.missionDateLabel.text = date
            self.missionLocation.text = self.mission.getLocationString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        self.card.layer.shadowColor = UIColor.black.cgColor
        self.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.card.layer.shadowOpacity = 0.25
        self.card.layer.shadowRadius = 2
    }
}
