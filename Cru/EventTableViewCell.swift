//
//  EventTableViewCell.swift
//  Cru
//
//  Created by Deniz Tumer on 4/28/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var spaceToTopCard: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var card: UIView!
    
    var event: Event! {
        didSet {
            let dateFormatter = "MMM d, yyyy"
            let timeFormatter = "h:mma"
            
            let startDate = GlobalUtils.stringFromDate(event.startNSDate, format: dateFormatter)
            let startTime = GlobalUtils.stringFromDate(event.startNSDate, format: timeFormatter)
            let endDate = GlobalUtils.stringFromDate(event.endNSDate, format: dateFormatter)
            let endTime = GlobalUtils.stringFromDate(event.endNSDate, format: timeFormatter)
            let location = GlobalUtils.stringFromLocation(event.location)
            
            eventTitleLabel.text = event.name
            if startDate != endDate {
                dateLabel.text = startDate + " - " + endDate
            }
            else {
                dateLabel.text = startDate
            }
            
            timeLabel.text = startTime + " - " + endTime
            locationLabel.text = location
            
            if event.imageUrl == "" {
                eventImage.isHidden = true
                spaceToTopCard.constant = 8
            }
            else {
                eventImage.isHidden = false
                spaceToTopCard.constant = 158
                //eventImage.load(event.imageUrl)
                eventImage.load.request(with: event.imageUrl)
            }
        }
    }
}
