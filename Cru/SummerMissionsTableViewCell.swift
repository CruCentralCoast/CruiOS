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
    
    var mission: SummerMission! {
        didSet {
            let dateFormat = "MMM d, yyyy"
            let startDate = GlobalUtils.stringFromDate(mission.startNSDate, format: dateFormat)
            let endDate = GlobalUtils.stringFromDate(mission.endNSDate, format: dateFormat)
            let date = startDate + " - " + endDate
            
            missionImage.load(mission.imageLink)
            missionName.text = mission.name
            missionDateLabel.text = date
            missionLocation.text = mission.getLocationString()
        }
    }
}
