//
//  AudioManager.swift
//  Cru
//
//  Created by Erica Solum on 9/15/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import AVFoundation

class AudioManager {
    // MARK: - Shared Instance
    static let sharedInstance = AudioManager()
    
    // MARK: - Local Variables
    private var audioPlayer: AVPlayer?
    private var audioFile: Audio?
    private var curObserver: NSObject?
    var delegate: AudioPlayerDelegate?
    var timer: Timer!
    //var curTimePosition = 0.0 // Current time in the track in seconds
    //var newTimePosition = 0.0 // Used when going forward or rewinding
    //var duration = 0.0 // The duration of the audio file in seconds
    var playAfterPause = false

    private init() {}
    
    
    // TODO: Implement playing at set time in audio file?
    
    // MARK: - Play Functions
    func playNewItem(audioFile: Audio, newDelegate: AudioPlayerDelegate) {
        if let player = audioPlayer {
            player.pause()
        }
        
        self.audioFile = audioFile
        
        if audioPlayer?.currentItem != nil {
            self.delegate?.pauseMedia()
            audioPlayer?.replaceCurrentItem(with: audioFile.playerItem)
            
        }
        
        else {
            audioPlayer = AVPlayer(playerItem: audioFile.playerItem)
        }
        
        self.delegate = newDelegate
        audioPlayer?.seek(to: audioFile.curTime)
        audioPlayer?.play()
        startTimer()
    }
    
    func playCurrentItem() {
        if let player = audioPlayer {
            player.seek(to: (audioFile?.curTime)!)
            player.play()
        }
    }
    
    func isPlaying() -> Bool{
        if let player = audioPlayer {
            if player.rate != 0 && player.error == nil{
                return true
            }
        }
        return false
    }
    
    func isCurrentlyPlaying(playerItem: AVPlayerItem) -> Bool{
        if let player = audioPlayer {
            if self.audioPlayer?.currentItem == playerItem {
                return true
            }
        }
        return false
    }
    
    func isCurrentlyPlaying(audioFile: Audio) -> Bool{
        if let file = self.audioFile {
            if file == audioFile {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Pause Functions
    func pauseItem() {
        if let player = audioPlayer {
            player.pause()
        }
    }
    func pauseForRewindOrForward() {
        if let player = audioPlayer {
            player.pause()
            playAfterPause = true
        }
    }
    
    // MARK: - Seeking Functions
    func seekTo(seconds: Double) {
        audioPlayer?.seek(to: CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    func seekToZero() {
        audioPlayer?.seek(to: kCMTimeZero)
    }
    
    func startTimer() {
        delegate?.timerSet()
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
            self?.audioFile?.curTime = curTime
            self?.audioFile?.curTimePosition = CMTimeGetSeconds(curTime)
            self?.delegate?.timerUpdate(curTime)
            
        }
    }
    
    // MARK: - Getter Functions
    
    func getCurrentItem() -> AVPlayerItem? {
        if let item = audioPlayer?.currentItem {
            return item
        }
        return nil
    }
    
    func getCurrentTime() -> CMTime? {
        if let player = audioPlayer {
            return player.currentTime()
        }
        return nil
    }
}

protocol AudioPlayerDelegate {
    func timerUpdate(_ time: CMTime)
    func timerSet()
    func pauseMedia()
}
