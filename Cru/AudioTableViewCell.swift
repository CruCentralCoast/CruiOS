//
//  AudioTableViewCell.swift
//  Cru
//
//  Created by Erica Solum on 3/6/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import AVFoundation

class AudioTableViewCell: UITableViewCell {
    
    var audioString: String!
    var gradientLayer: CAGradientLayer!
    var cardGutterSpace = 8
    var audioPlayer: AVPlayer?
    var playerItem:AVPlayerItem?
    var formatter = DateFormatter()
    var timer: Timer!
    var curTimePosition = 0.0 // Current time in the track in seconds
    var newTimePosition = 0.0 // Used when going forward or rewinding
    var duration = 0.0 // The duration of the audio file in seconds
    
    var audioFileLoaded = false
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
        
    }
    
    //Called in ResourcesViewController once the audioString has been set
    func prepareAudioFile() {
        let audioURL = URL(string: audioString)
        if audioURL != nil {
            let audioAsset = AVURLAsset(url: audioURL!)
            //audioFile = try? AKAudioFile(forReading: audioURL!)
            //audioFilePlayer = try? AKAudioPlayer(file: audioFile!)
            playerItem = AVPlayerItem(asset: audioAsset, automaticallyLoadedAssetKeys: nil)
            audioPlayer = AVPlayer(playerItem: playerItem)
            
            
            //Get duration of file and display the nicely formatted string
            let durTime = audioAsset.duration
            duration = CMTimeGetSeconds(durTime)
            totalTime.text! = ResourceUtils.getStringFromCMTime(durTime)
            
            //Display the starting time with correct amount of leading zeros
            curPosition.text! = ResourceUtils.getStringFromCMTime((audioPlayer?.currentTime())!)
            
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
    }
    
    //Slider action
    @IBAction func timeChanged(_ sender: UISlider) {
        let value = playbackSlider.value
        audioPlayer?.seek(to: CMTime(seconds: Double(value),
                                     preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        //playbackSlider.setSliderWithGradientColors(color: CruColors.yellow, color2: CruColors.orange)
    }
    
    //Rewind button 'rapid fire' methods
    func rewindPressed(_ sender: UIButton) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioTableViewCell.rewind), userInfo: nil, repeats: true)
        newTimePosition = curTimePosition
        audioPlayer?.pause()
        
    }
    
    //Function that is called when the rewind button is released
    func rewindUp(_ sender: UIButton) {
        timer.invalidate()
        
        audioPlayer?.seek(to: CMTime(seconds: newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        audioPlayer?.play()
    }
    
    //Function called continuously while rewinding
    func rewind() {
        //Update slider and label only if starting past the beginning
        if newTimePosition > 0 {
            newTimePosition -= 1
            
            //Update the current position label and slider position
            curPosition.text! = ResourceUtils.getStringFromCMTime(
                CMTime(seconds: newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            playbackSlider.setValue(Float(newTimePosition), animated: false)
            
        } else {
            timer.invalidate()
        }
    }
    
    //Forward button 'rapid fire' methods
    func forwardPressed(_ sender: UIButton) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioTableViewCell.forward), userInfo: nil, repeats: true)
        newTimePosition = curTimePosition
        audioPlayer?.pause()
        
    }
    
    //Function that is called when the rewind button is released
    func forwardUp(_ sender: UIButton) {
        timer.invalidate()
        
        audioPlayer?.seek(to: CMTime(seconds: newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        audioPlayer?.play()
    }
    
    //Function called continuously while rewinding
    func forward() {
        //Update slider and label only if starting past the beginning
        if newTimePosition < duration {
            newTimePosition += 1
            
            //Update the current position label and slider position
            curPosition.text! = ResourceUtils.getStringFromCMTime(
                CMTime(seconds: newTimePosition, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            playbackSlider.setValue(Float(newTimePosition), animated: false)
            
        } else {
            timer.invalidate()
        }
    }

    
    //Play/pause button action method
    @IBAction func playPauseButtonClicked(_ sender: UIButton) {
        
        if audioFileLoaded == false {
            prepareAudioFile()
            audioFileLoaded = true
        }
        
        if audioPlayer?.rate == 0
        {
            audioPlayer!.play()
            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
            playButton!.setImage(pauseImage, for: .normal)
        } else {
            audioPlayer!.pause()
            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
            playButton!.setImage(playImage, for: .normal)
        }
    }

}
