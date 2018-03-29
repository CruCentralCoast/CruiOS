//
//  AudioResourcesTableViewCell.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/29/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class AudioResourcesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var lengthOfAudio: Int = 100
    
    override func awakeFromNib() {
        self.progressBar.progress = 0
        self.currentTimeLabel.text = self.secondsToTimeString(numberOf: 0)
        self.endTimeLabel.text = self.secondsToTimeString(numberOf: self.lengthOfAudio)
    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        sender.tintColor = sender.tintColor == .cruBlue ? .red : .cruBlue
    }
    
    private func secondsToTimeString(numberOf seconds: Int) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: Double(seconds))
        return String(format: "%02d:%02d:%02d", Int(h), Int(m), Int(s))
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Double) -> (Double, Double, Double) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (hr, min, 60 * secf)
    }
}
