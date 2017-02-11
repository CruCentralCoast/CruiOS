//
//  NSURLExtensions.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 4/23/15.
//
//

import Foundation

public extension URL{
    
    func isTwitterProfileURL()->Bool{
        let length:Int = absoluteString.lengthOfBytes(using: String.Encoding.utf8)
        if (length > 0) {
            let pattern = "^http(s)://(www.)?twitter.com/(\\w*)\\/?$"
            let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let length:Int = absoluteString.lengthOfBytes(using: String.Encoding.utf8)
            let ytMatch = regex?.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, length))
            if(ytMatch != nil){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
    
    func isTwitterTweetURL()->Bool{
        let length:Int = absoluteString.lengthOfBytes(using: String.Encoding.utf8)
        if (length > 0) {
            let pattern = "^http(s)://(www.)?twitter.com/(\\w*)/status/(\\d*)\\/?$"
            let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let ytMatch = regex?.firstMatch(in: absoluteString, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, length))
            if(ytMatch != nil){
                return true
            }else{
                return false
            }
        }else{
            return false
        }
    }
}
