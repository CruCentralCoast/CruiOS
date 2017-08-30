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
            let startDate = GlobalUtils.stringFromDate(mission.startNSDate, format: dateFormat)
            let endDate = GlobalUtils.stringFromDate(mission.endNSDate, format: dateFormat)
            let date = startDate + " - " + endDate
            
            if mission.imageLink != "" {
                let urlRequest = URLRequest(url: URL(string: mission.imageLink)!)
                CruClients.getImageUtils().getImageDownloader().download(urlRequest) { response in
                    if let image = response.result.value {
                        self.missionImage.image = image
                    }
                }
            }
            //missionImage.load.request(with: mission.imageLink)
            missionName.text = mission.name
            missionDateLabel.text = date
            missionLocation.text = mission.getLocationString()
        }
    }
}
