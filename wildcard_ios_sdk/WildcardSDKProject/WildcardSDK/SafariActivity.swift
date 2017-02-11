//
//  SafariActivity.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/30/15.
//
//

import Foundation
import UIKit

class SafariActivity : UIActivity
{
    
    var activityItems:[AnyObject]?
    
    override var activityType : UIActivityType? {
        return UIActivityType.init("wildcard.openInSafari")
    }
    
    
    override var activityTitle : String? {
        return "Open in Safari"
    }
    
    override var activityImage : UIImage? {
        return UIImage.loadFrameworkImage("safariIcon")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for object in activityItems{
            if object is URL {
                return true
            }
        }
        return false
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        self.activityItems = activityItems as [AnyObject]?
    }
    
    override func perform() {
        var opened = false
        
        if let items = activityItems{
            for object in items{
                if let url = object as? URL{
                    if(UIApplication.shared.canOpenURL(url)){
                        opened = UIApplication.shared.openURL(url)
                    }else{
                        opened = false
                    }
                }
            }
        }
        
        activityDidFinish(opened)
    }
}
