//
//  YoutubeThumbnail.swift
//  Cru
//
//  Source: https://gist.github.com/freerunnering/03d5cf4ff42be13f00f6
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

/**
 What size and quailty youtube thumbnail you want.
 - Zero:     Player Background: (480x360 pixels) (same as High)
 - One:      Start: (120x90 pixels)
 - Two:      Middle: (120x90 pixels)
 - Three:    End: (120x90 pixels)
 - Default:  Normal: (120x90 pixels)
 - Medium:   Medium: (320x180 pixels)
 - High:     High: (480x360 pixels) (same as 0)
 - Standard: SD: (640x480 pixels) (HQ videos only)
 - Max:      HD: (1920x1080 pixels) (HQ videos only)
 */
enum ThumbnailQuailty : String {
    case Zero = "0.jpg"
    case One = "1.jpg"
    case Two = "2.jpg"
    case Three = "3.jpg"
    
    case Default = "default.jpg"
    case Medium = "mqdefault.jpg"
    case High = "hqdefault.jpg"
    case Standard = "sddefault.jpg"
    case Max = "maxresdefault.jpg"
    
    /// All values sorted by image size (1,2,3 are the same size)
    static let allValues = [Default, One, Two, Three,  Medium, High, Zero, Standard, High]
}

func thumbnailURLString(_ videoID:String, quailty: ThumbnailQuailty = .Medium) -> String {
    //return "http://img.youtube.com/vi/\(videoID)/\(quailty.rawValue)"
    return "http://i1.ytimg.com/vi/\(videoID)/\(quailty.rawValue)"
}
