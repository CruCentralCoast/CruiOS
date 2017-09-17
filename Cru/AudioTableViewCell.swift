//
//  AudioTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 3/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewCell: UITableViewCell, AudioPlayerDelegate {
    
    var audio: Audio! {
        didSet {
            //Set up slider max value to match the audio file when
            playbackSlider.maximumValue = Float(CMTimeGetSeconds((audio.audioAsset?.duration)!))
            //Get duration of file and display the nicely formatted string
            totalTime.text! = ResourceUtils.getStringFromCMTime((audio.audioAsset?.duration)!)
            //Display the starting time with correct amount of leading zeros
            curPosition.text! = ResourceUtils.getStringFromCMTime(audio.curTime)
        }
    }
    //var audioString: String!
    var gradientLayer: CAGradientLayer!
    var cardGutterSpace = 8
    //var audioPlayer: AVPlayer?
    //var playerItem:AVPlayerItem?
    var formatter = DateFormatter()
    var timer: Timer!
    //var curTimePosition = 0.0 // Current time in the track in seconds
    //var newTimePosition = 0.0 // Used when going forward or rewinding
    //var duration = 0.0 // The duration of the audio file in seconds
    
    var playImage = UIImage(named: "play")
    var pauseImage = UIImage(named: "pause")
    
    var timeFormat = "HH:mm:ss"

    //MARK: UI Outlets & Constraints
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var curPosition: UILabel!
    @IBOutlet weak var playbackSlider: PlaybackSlider!
    
    @IBOutlet weak var playWidth: NSLayoutConstraint!
    @IBOutlet weak var rewindWidth: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Set up time formatter to be used later
        
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = timeFormat
        
        //Set width of buttons to be equal
        calculateButtonWidth()
        
        //Set up the inital state of the playback indicator
        setupPlaybackSlider()
        
        //Add button targets
        rewindButton.addTarget(self, action: #selector(AudioTableViewCell.rewindPressed(_:)), for: .touchDown)
        rewindButton.addTarget(self, action: #selector(AudioTableViewCell.rewindUp(_:)), for: [.touchUpInside, .touchUpOutside])
        forwardButton.addTarget(self, action: #selector(AudioTableViewCell.forwardPressed(_:)), for: .touchDown)
        forwardButton.addTarget(self, action: #selector(AudioTableViewCell.forwardUp(_:)), for: [.touchUpInside, .touchUpOutside])
        
    }
    
    //Calculate the exact width of the play/pause, rewind & forward buttons at runtime
    func calculateButtonWidth() {
        //Have to do calculate with screen width because using
        //card width yields incorrect value
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let cardWidth = screenWidth - CGFloat(integerLiteral: cardGutterSpace*2)
        
        let buttonWidth = cardWidth / 3
        
        
        playWidth.constant = buttonWidth
        rewindWidth.constant = buttonWidth
    }
    
    //Calculate gradient for playback slider
    func setupPlaybackSlider() {
        playbackSlider.minimumTrackTintColor = CruColors.yellow
        //playbackSlider.maximumTrackTintColor = CruColors.orange
        
        playbackSlider.minimumValue = 0
        playbackSlider.isContinuous = false
        
        playbackSlider.setThumbImage(UIImage(named: "position-indicator"), for: .normal)
        playbackSlider.value = 0
        playbackSlider.maximumValue = 600
        
    }
    
    //Called in ResourcesViewController once the audioString has been set
    /*func prepareAudioFile() {
        let audioURL = URL(string: audioString)
        if audioURL != nil {
            let audioAsset = AVURLAsset(url: audioURL!)
            //audioFile = try? AKAudioFile(forReading: audioURL!)
            //audioFilePlayer = try? AKAudioPlayer(file: audioFile!)
            //playerItem = AVPlayerItem(asset: audioAsset, automaticallyLoadedAssetKeys: nil)
            //AudioManager.sharedInstance.audioPlayer = AVPlayer(playerItem: playerItem)
            
            
            //Get duration of file and display the nicely formatted string
            let durTime = audioAsset.duration
            duration = CMTimeGetSeconds(durTime)
            
            
            
            
            // Invoke callback every second
            let interval = CMTime(seconds: 1.0,
                                  preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            // Queue on which to invoke the callback
            let mainQueue = DispatchQueue.main
            // Add time observer
            _ = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
                    [weak self] time in
                    // update player transport UI
                    let curTime = (self?.audioPlayer?.currentTime())!
                    self?.curTimePosition = CMTimeGetSeconds(curTime)
                    self?.curPosition.text! = ResourceUtils.getStringFromCMTime(curTime)
                    self?.playbackSlider.setValue(Float(CMTimeGetSeconds(curTime)), animated: false)
                
            }
            
            //Set up slider max value to match the audio file
            playbackSlider.maximumValue = Float(CMTimeGetSeconds(durTime))
        }
    }*/
    
    // MARK: - Audio Manipulation Actions
    
    //Changing time via slider
    @IBAction func timeChanged(_ sender: UISlider) {
        let value = playbackSlider.value
        let seconds = Double(value)
        
        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: self.audio) {
            AudioManager.sharedInstance.seekTo(seconds: seconds)
        }
        
        // TODO: Update current position text here?
        self.audio.curTimePosition = seconds
        self.audio.curTime = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.curPosition.text = ResourceUtils.getStringFromCMTime(self.audio.curTime)
        
        //audioPlayer?.seek(to: CMTime(seconds: Double(value), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        //playbackSlider.setSliderWithGradientColors(color: CruColors.yellow, color2: CruColors.orange)
    }
    
    
    //Rewind button 'rapid fire' methods
    func rewindPressed(_ sender: UIButton) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioTableViewCell.rewind), userInfo: nil, repeats: true)
        //newTimePosition = curTimePosition
        self.audio.newTimePosition = self.audio.curTimePosition
        
        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: audio) {
           AudioManager.sharedInstance.pauseForRewindOrForward()
        }
        
    }
    
    //Function that is called when the rewind button is released
    func rewindUp(_ sender: UIButton) {
        timer.invalidate()
        
        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: audio) {
            AudioManager.sharedInstance.seekTo(seconds: audio.newTimePosition)
            if AudioManager.sharedInstance.playAfterPause {
                AudioManager.sharedInstance.playCurrentItem()
                AudioManager.sharedInstance.playAfterPause = false
            }
        }
        
        //audioPlayer?.seek(to: CMTime(seconds: newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        //audioPlayer?.play()
    }
    
    //Function called continuously while rewinding
    func rewind() {
        //Update slider and label only if starting past the beginning
        if audio.newTimePosition > 0 {
            audio.newTimePosition -= 1
            
            //Update the current position label and slider position
            curPosition.text! = ResourceUtils.getStringFromCMTime(
                CMTime(seconds: audio.newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            playbackSlider.setValue(Float(audio.newTimePosition), animated: false)
            
        } else {
            timer.invalidate()
        }
    }
    
    //Forward button 'rapid fire' methods
    func forwardPressed(_ sender: UIButton) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioTableViewCell.forward), userInfo: nil, repeats: true)
        audio.newTimePosition = audio.curTimePosition

        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: audio) {
            AudioManager.sharedInstance.pauseForRewindOrForward()
        }
        
    }
    
    //Function that is called when the rewind button is released
    func forwardUp(_ sender: UIButton) {
        timer.invalidate()
        
        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: self.audio) {
            AudioManager.sharedInstance.seekTo(seconds: audio.newTimePosition)
            if AudioManager.sharedInstance.playAfterPause {
                AudioManager.sharedInstance.playCurrentItem()
                AudioManager.sharedInstance.playAfterPause = false
            }
        }
    }
    
    //Function called continuously while rewinding
    func forward() {
        //Update slider and label only if starting past the beginning
        if audio.newTimePosition < audio.duration {
            audio.newTimePosition += 1
            
            //Update the current position label and slider position
            curPosition.text! = ResourceUtils.getStringFromCMTime(
                CMTime(seconds: audio.newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            playbackSlider.setValue(Float(audio.newTimePosition), animated: false)
            
        } else {
            timer.invalidate()
        }
    }

    
    //Play/pause button action method
    @IBAction func playPauseButtonClicked(_ sender: UIButton) {
        print("CLICKED PLAY")
        // Handle same audio file
        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: self.audio) {
            
            //Handle pause
            if AudioManager.sharedInstance.isPlaying() {
                // Update and store place
                if let curTime = AudioManager.sharedInstance.getCurrentTime() {
                    self.audio.curTime = curTime
                    self.audio.curTimePosition = CMTimeGetSeconds(curTime)
                }
                
                AudioManager.sharedInstance.pauseItem()
                playButton!.setImage(playImage, for: .normal)
            }
            else {
                AudioManager.sharedInstance.playCurrentItem()
            }
        }
        // Handle playing new item
        else {
            AudioManager.sharedInstance.removeStatusObserver()
            
            AudioManager.sharedInstance.delegate = self
            AudioManager.sharedInstance.playNewItem(audioFile: self.audio)
            AudioManager.sharedInstance.addObserver(obj: self)
            playButton!.setImage(pauseImage, for: .normal)
        }
    }
    
    // MARK: - Audio Player Delegate Function
    func timerUpdate(_ time: CMTime) {
        self.curPosition.text! = ResourceUtils.getStringFromCMTime(time)
        self.playbackSlider.setValue(Float(CMTimeGetSeconds(time)), animated: false)
        self.audio.curTime = time
        self.audio.curTimePosition = CMTimeGetSeconds(time)
    }
    
    // MARK: - Observer Functions for Player status
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            let oldStatus: AVPlayerItemStatus
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            if let statusNumber = change?[.oldKey] as? NSNumber {
                oldStatus = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                oldStatus = .unknown
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
            // Player item is ready to play.
                print("new status: Ready to play")
            case .failed:
            // Player item failed. See error.
                print("new status: Failed")
            case .unknown:
                print("new status: Unkown")
            }
            
            // Switch over the status
            switch oldStatus {
            case .readyToPlay:
                // Player item is ready to play.
                print("old status: Ready to play")
            case .failed:
                // Player item failed. See error.
                print("old status: Failed")
            case .unknown:
                print("old status: Unkown")
            }
            
        }
        else if keyPath == #keyPath(AVPlayer.rate) {
            let oldRate: Float
            let newRate: Float
            // Get the status change from the change dictionary
            if let number = change?[.newKey] as? Float {
                newRate = number
                print("new rate: \(newRate)")
            } else {
                newRate = -5
            }
            // Get the status change from the change dictionary
            if let number = change?[.oldKey] as? Float {
                oldRate = number
                print("old rate: \(oldRate)")
            } else {
                oldRate = -5
            }
        }

        
    }
}
