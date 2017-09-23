//
//  AudioTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 3/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import AVFoundation
import MRProgress

class AudioTableViewCell: UITableViewCell, AudioPlayerDelegate {
    
    var audio: Audio! {
        didSet {
            //Set up slider max value to match the audio file when
            playbackSlider.maximumValue = Float(CMTimeGetSeconds((audio.audioAsset?.duration)!))
            
            playbackSlider.value = Float(audio.curTimePosition)
            //Get duration of file and display the nicely formatted string
            totalTime.text! = ResourceUtils.getStringFromCMTime((audio.audioAsset?.duration)!)
            //Display the starting time with correct amount of leading zeros
            curPosition.text! = ResourceUtils.getStringFromCMTime(audio.curTime)
            AudioManager.sharedInstance.continueIfPlayingItem(audioFile: self.audio, newDelegate: self)
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
    var activityIndicator: UIActivityIndicatorView?
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audio.playerItem)
        print("De initing")
        AudioManager.sharedInstance.delegate = nil
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
        audio.curTime = CMTime(seconds: audio.newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
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
        
        audio.curTime = CMTime(seconds: audio.newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
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
        // Handle same audio file
        if AudioManager.sharedInstance.isCurrentlyPlaying(audioFile: self.audio) {
            
            //Handle pause
            if AudioManager.sharedInstance.isPlaying() {
                // Update and store place
                if let curTime = AudioManager.sharedInstance.getCurrentTime() {
                    self.audio.curTime = curTime
                    self.audio.curTimePosition = CMTimeGetSeconds(curTime)
                }
                print("Pausing item")
                AudioManager.sharedInstance.pauseItem()
                playButton!.setImage(playImage, for: .normal)
            }
            else {
                AudioManager.sharedInstance.playCurrentItem()
                playButton!.setImage(pauseImage, for: .normal)
            }
        }
        // Handle playing new item
        else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.audio.playerItem)
            AudioManager.sharedInstance.playNewItem(audioFile: self.audio, newDelegate: self)
            playButton!.setImage(pauseImage, for: .normal)
        }
    }
    
    func playerDidFinishPlaying() {
        // Your code here
        DispatchQueue.main.async(){
            self.playButton!.setImage(self.playImage, for: .normal)
            self.audio.curTime = kCMTimeZero
            //AudioManager.sharedInstance.seekToZero()
        }
        
    }
    
    // MARK: - Audio Player Delegate Functions
    func timerUpdate(_ time: CMTime) {
        if let act = activityIndicator {
            if act.isAnimating {
                activityIndicator?.stopAnimating()
                self.playButton.setImage(self.pauseImage, for: .normal)
                /*DispatchQueue.main.async(){
                    self.playButton.setImage(self.pauseImage, for: .normal)
                }*/
            }
            
        }
        print("Updating timer")
        //self.playButton.setImage(self.pauseImage, for: .normal)
        
        //playButton.setImage(pauseImage, for: .normal)
        self.curPosition.text! = ResourceUtils.getStringFromCMTime(time)
        self.playbackSlider.setValue(Float(CMTimeGetSeconds(time)), animated: false)
        self.audio.curTime = time
        self.audio.curTimePosition = CMTimeGetSeconds(time)
    }
    
    //set the button to show paused state
    func pauseMedia() {
        DispatchQueue.main.async(){
            self.playButton!.setImage(self.playImage, for: .normal)
        }
    }
    
    func playMedia() {
        DispatchQueue.main.async(){
            self.playButton!.setImage(self.pauseImage, for: .normal)
        }
    }
    
    func timerSet() {
        if self.audio.curTimePosition == 0 {
            DispatchQueue.main.async(){
                if self.activityIndicator == nil {
                    self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    self.activityIndicator?.hidesWhenStopped = true
                    /*activityIndicator.center = activityView.center
                     activityIndicator.startAnimating()
                     activityView.addSubview(activityIndicator)*/
                    let halfButtonHeight = self.playButton.bounds.size.height/2
                    let buttonWidth = self.playButton.bounds.size.width
                    self.activityIndicator?.center = CGPoint(x: buttonWidth/2, y: halfButtonHeight)
                    self.playButton.setImage(nil, for: .normal)
                    self.playButton.addSubview(self.activityIndicator!)
                    self.activityIndicator?.startAnimating()
                }
                else {
                    self.activityIndicator?.startAnimating()
                }
            }
        }
        
    }
}
