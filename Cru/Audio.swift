//
//  Audio.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import AVFoundation

class Audio: NSObject {
    // MARK: Properties
    var title: String!
    var author: String!
    var id: String!
    var url: String!
    var date: Date!
    var tags: [String]!
    var restricted: Bool!
   
    var audioAsset: AVURLAsset?
    var playerItem: AVPlayerItem?
    var curTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    var curTimePosition = 0.0 // Current time in the track in seconds
    var newTimePosition = 0.0 // Used when going forward or rewinding
    var duration = 0.0 // The duration of the audio file in seconds
    var fileLoaded = false
    
    init(id: String?, title: String?, url: String?, date: Date?, tags: [String]?, restricted: Bool!) {
        // Initialize properties
        self.id = id
        self.title = title
        self.url = url
        self.date = date
        self.tags = tags
        self.restricted = restricted
    }
    
    convenience override init() {
        self.init(id: "", title: "", url: "", date: nil, tags: [], restricted: false)
    }
    
    func prepareAudioFile() {
        let audioURL = URL(string: url)
        if audioURL != nil {
            audioAsset = AVURLAsset(url: audioURL!)
            //audioFile = try? AKAudioFile(forReading: audioURL!)
            //audioFilePlayer = try? AKAudioPlayer(file: audioFile!)
            let assetKeys = [
                "playable",
                "hasProtectedContent"
            ]
            
            if let asset = audioAsset {
                playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
                let durTime = asset.duration
                duration = CMTimeGetSeconds(durTime)
                fileLoaded = true
            }
            
            
            //Get duration of file and display the nicely formatted string
            
            //totalTime = ResourceUtils.getStringFromCMTime(durTime)
            
            //Display the starting time with correct amount of leading zeros
            //curPosition.text! = ResourceUtils.getStringFromCMTime((audioPlayer?.currentTime())!)
            
        }

    }
    
    // MARK: - Audio Player Delegate Functions
    /*func timerUpdate(_ time: CMTime) {
        if let act = activityIndicator {
            if act.isAnimating {
                activityIndicator?.stopAnimating()
                /*DispatchQueue.main.async(){
                 self.playButton.setImage(self.pauseImage, for: .normal)
                 }*/
            }
            
        }
        print("Updating timer")
        self.playButton.setImage(self.pauseImage, for: .normal)
        
        //playButton.setImage(pauseImage, for: .normal)
        self.curPosition.text! = ResourceUtils.getStringFromCMTime(time)
        self.playbackSlider.setValue(Float(CMTimeGetSeconds(time)), animated: false)
        self.audio.curTime = time
        self.audio.curTimePosition = CMTimeGetSeconds(time)
    }*/
    
    
}

// MARK: - AVPlayer Item Extension to add Audio variable
/*public final class ObjectAssociation<T: AnyObject> {
    
    private let policy: objc_AssociationPolicy
    
    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        
        self.policy = policy
    }
    
    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        
        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
    }
}

extension AVPlayerItem {
    private static let association = ObjectAssociation<Audio>()
    
    var audioFile: Audio! {
        get {
            return AVPlayerItem.association[self]
        }
        set {
            AVPlayerItem.association[self] = newValue
        }
    }
}*/
