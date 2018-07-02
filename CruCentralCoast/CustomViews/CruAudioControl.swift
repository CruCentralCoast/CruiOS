//
//  CruAudioControl.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/29/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import AVKit

class CruAudioControl: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pauseButton: UIButton!
    
    var audioResourceDelegate: AudioResourceDelegate?
    private var audioPlayer: AVPlayer?
    private var isPaused = true {
        didSet {
            if self.isPaused {
                self.pauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                self.audioPlayer?.pause()
            } else {
                self.pauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                self.audioPlayer?.play()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.showAVPlayerViewController))
        self.addGestureRecognizer(tapGesture)
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.audioPlayer = nil
        self.audioResourceDelegate?.dismissMiniAudioPlayer()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        self.isPaused = !self.isPaused
    }
    
    @objc private func showAVPlayerViewController() {
        if let player = self.audioPlayer {
            self.audioResourceDelegate?.showAVPlayerViewController(player: player)
        }
    }
    
    func playAudioFromURL(url: URL) {
        let avAsset = AVURLAsset(url: url)
        let playerItem = AVPlayerItem(asset: avAsset)
        self.audioPlayer = AVPlayer(playerItem: playerItem)
        self.audioPlayer?.play()
        self.progressView.progress = 0
        self.currentTimeLabel.text = self.secondsToTimeString(numberOf: 0)
        self.endTimeLabel.text = self.secondsToTimeString(numberOf: 0)
        self.pauseButton.isHidden = true
        self.activityIndicator.startAnimating()
        self.audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main) { time in
            let currentSeconds = time.seconds
            if self.activityIndicator.isAnimating && currentSeconds == 0 {
                self.pauseButton.isHidden = false
                self.activityIndicator.stopAnimating()
                self.isPaused = false
            }
            if let item = self.audioPlayer?.currentItem {
                if !item.duration.seconds.isNaN && !currentSeconds.isNaN {
                    self.progressView.progress = Float(currentSeconds/item.duration.seconds)
                    self.endTimeLabel.text = self.secondsToTimeString(numberOf: Float(item.duration.seconds))
                    self.currentTimeLabel.text = self.secondsToTimeString(numberOf: Float(currentSeconds))
                }
            }
        }
    }
    
    private func secondsToTimeString(numberOf seconds: Float) -> String {
        let (h, m, s) = self.secondsToHoursMinutesSeconds(seconds: seconds)
        return String(format: "%02d:%02d:%02d", Int(h), Int(m), Int(s))
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Float) -> (Float, Float, Float) {
        let (hr,  minf) = modf (seconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (hr, min, 60 * secf)
    }
}

extension CruAudioControl : AVPlayerViewControllerDelegate {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !self.isPaused && self.audioPlayer?.rate == 0 {
            self.audioPlayer?.play()
        }
    }
}
