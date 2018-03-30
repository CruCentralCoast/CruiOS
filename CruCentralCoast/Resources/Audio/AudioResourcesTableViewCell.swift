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
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var playPauseButton: UIButton!
    
    var currentTime: Float = 3 {
        didSet {
            self.currentTimeLabel.text = self.secondsToTimeString(numberOf: self.currentTime)
        }
    }
    var duration: Float = 10
    var audioIsPlaying: Bool = false {
        didSet {
            playPauseButton.tintColor = self.audioIsPlaying ? .gray : .cruBlue
        }
    }
    
    override func awakeFromNib() {
        self.updateView()
    }
    
    override func prepareForReuse() {
        self.updateView()
    }
    
    private func updateView() {
        self.audioIsPlaying = false
        self.progressBar.progress = self.currentTime/self.duration
        self.currentTimeLabel.text = self.secondsToTimeString(numberOf: self.currentTime)
        self.durationLabel.text = self.secondsToTimeString(numberOf: self.duration)
        self.progressBar.setProgress(self.currentTime/self.duration, animated: false)
    }
    
    @IBAction func playPausePressed(_ sender: UIButton) {
        self.audioIsPlaying = !self.audioIsPlaying
    }
    
    private func secondsToTimeString(numberOf seconds: Float) -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds(seconds: seconds)
        return String(format: "%02d:%02d:%02d", Int(h), Int(m), Int(s))
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Float) -> (Float, Float, Float) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (hr, min, 60 * secf)
    }
}
