//
//  ResourceUtils.swift
//  Cru
//
//  Created by Erica Solum on 3/8/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import CoreMedia

class ResourceUtils {
    
    //Get a nicely formatted string given a CMTime object
    
    class func getStringFromCMTime(_ time: CMTime) -> String{
        let cmSeconds = Int(CMTimeGetSeconds(time))
        let hours = cmSeconds / 3600
        let minutes = (cmSeconds % 3600) / 60
        let seconds = cmSeconds % 60
        
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}

