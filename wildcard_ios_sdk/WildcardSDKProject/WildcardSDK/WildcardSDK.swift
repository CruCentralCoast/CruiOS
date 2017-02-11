//
//  WildcardSDK.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/22/15.
//
//

import Foundation

/// Global convenience settings

@objc
open class WildcardSDK: NSObject {
    
    static var sharedInstance: WildcardSDK = WildcardSDK()
    
    override init() {
        __cardTitleFont = UIFont(name:"HelveticaNeue-Medium", size: 16.0)!
        __cardTitleColor = UIColor.wildcardDarkBlue()
        __cardKickerFont = UIFont(name:"HelveticaNeue-Medium", size: 12.0)!
        __cardKickerColor = UIColor.wildcardMediumGray()
        __cardDescriptionFont = UIFont(name:"HelveticaNeue", size: 12.0)!
        __cardDescriptionColor = UIColor.wildcardMediaBodyColor()
        __cardActionButtonFont = UIFont(name:"HelveticaNeue-Medium", size: 12.0)!
        __networkDelegateQueue = OperationQueue.main
        __cardBackgroundColor = UIColor.white
        __cardDropShadow = true
    }
    
    /*class var sharedInstance : WildcardSDK{
        struct Static{
            static var onceToken : Int = 0
            static var instance : WildcardSDK? = nil
        }
        
        _ = WildcardSDK.__once
        return Static.instance!
    }
 
    private static var __once: () = { () -> Void in
            Static.instance = WildcardSDK()
            Static.instance!.__cardTitleFont = UIFont(name:"HelveticaNeue-Medium", size: 16.0)!
            Static.instance!.__cardTitleColor = UIColor.wildcardDarkBlue()
            Static.instance!.__cardKickerFont = UIFont(name:"HelveticaNeue-Medium", size: 12.0)!
            Static.instance!.__cardKickerColor = UIColor.wildcardMediumGray()
            Static.instance!.__cardDescriptionFont = UIFont(name:"HelveticaNeue", size: 12.0)!
            Static.instance!.__cardDescriptionColor = UIColor.wildcardMediaBodyColor()
            Static.instance!.__cardActionButtonFont = UIFont(name:"HelveticaNeue-Medium", size: 12.0)!
            Static.instance!.__networkDelegateQueue = OperationQueue.main
            Static.instance!.__cardBackgroundColor = UIColor.white
            Static.instance!.__cardDropShadow = true
        }()*/
 
    /// Custom font for Card titles
    open class var cardTitleFont:UIFont{
        get{
            return WildcardSDK.sharedInstance.__cardTitleFont
        }set{
            WildcardSDK.sharedInstance.__cardTitleFont = newValue
        }
    }
    
    /// Custom color for Card titles
    open class var cardTitleColor:UIColor{
        get{
            return WildcardSDK.sharedInstance.__cardTitleColor
        }set{
            WildcardSDK.sharedInstance.__cardTitleColor = newValue
        }
    }
    
    /// Custom font for Card kickers
    open class var cardKickerFont:UIFont{
        get{
            return WildcardSDK.sharedInstance.__cardKickerFont
        }set{
            WildcardSDK.sharedInstance.__cardKickerFont = newValue
        }
    }
    
    /// Custom color for Card kickers
    open class var cardKickerColor:UIColor{
        get{
            return WildcardSDK.sharedInstance.__cardKickerColor
        }set{
            WildcardSDK.sharedInstance.__cardKickerColor = newValue
        }
    }
    
    /// Custom font for Card descriptions
    open class var cardDescriptionFont:UIFont{
        get{
            return WildcardSDK.sharedInstance.__cardDescriptionFont
        }set{
            WildcardSDK.sharedInstance.__cardDescriptionFont = newValue
        }
    }
    
    /// Custom color for Card descriptions
    open class var cardDescriptionColor:UIColor{
        get{
            return WildcardSDK.sharedInstance.__cardDescriptionColor
        }set{
            WildcardSDK.sharedInstance.__cardDescriptionColor = newValue
        }
    }
    
    /// Custom font for Card Action Buttons
    open class var cardActionButtonFont:UIFont{
        get{
            return WildcardSDK.sharedInstance.__cardActionButtonFont
        }set{
            WildcardSDK.sharedInstance.__cardActionButtonFont = newValue
        }
    }
    
    /// Card Corner Radius
    open class var cardCornerRadius:CGFloat{
        get{
            return WildcardSDK.sharedInstance.__cardCornerRadius
        }set{
            WildcardSDK.sharedInstance.__cardCornerRadius = newValue
        }
    }
    
    /// Delegate queue for network request callbacks
    open class var networkDelegateQueue:OperationQueue{
        get{
            return WildcardSDK.sharedInstance.__networkDelegateQueue;
        }set{
            WildcardSDK.sharedInstance.__networkDelegateQueue = newValue;
        }
    }
    
    /// Custom corner radius for images shown in cards
    open class var imageCornerRadius:CGFloat{
        get{
            return WildcardSDK.sharedInstance.__imageCornerRadius;
        }set{
            WildcardSDK.sharedInstance.__imageCornerRadius = newValue;
        }
    }
    
    /// This value is used to calculate a default preferred width for a CardView if none is explicilty given.
    open class var defaultScreenMargin:CGFloat{
        get{
            return WildcardSDK.sharedInstance.__defaultScreenMargin
        }set{
            WildcardSDK.sharedInstance.__defaultScreenMargin = newValue;
        }
    }
    
    /// The default background color for any card view
    open class var cardBackgroundColor:UIColor{
        get{
            return WildcardSDK.sharedInstance.__cardBackgroundColor
        }set{
            WildcardSDK.sharedInstance.__cardBackgroundColor = newValue
        }
    }
    
    /// Enables or disables a drop shadow on the card view, ON by default
    open class var cardDropShadow:Bool{
        get{
            return WildcardSDK.sharedInstance.__cardDropShadow
        }set{
            WildcardSDK.sharedInstance.__cardDropShadow = newValue
        }
    }
    
    /// Initialize the SDK
    open class func initializeWithApiKey(_ key:String){
        if(WildcardSDK.sharedInstance.__applicationKey == nil){
            WildcardSDK.sharedInstance.__applicationKey = key
            WildcardSDK.sharedInstance.__analytics = WCAnalytics(key:key)
        }else{
            print("Wildcard SDK can only be initialized once.")
        }
    }
    
    class var analytics:WCAnalytics?{
        get{
            return WildcardSDK.sharedInstance.__analytics;
        }
    }
    
    class var apiKey:String?{
        get{
            return WildcardSDK.sharedInstance.__applicationKey;
        }
    }
    
    var __imageCornerRadius:CGFloat = 1.0
    var __defaultScreenMargin:CGFloat = 15.0
    var __cardCornerRadius:CGFloat = 2.0
    var __cardTitleFont:UIFont!
    var __cardTitleColor:UIColor!
    var __cardKickerFont:UIFont!
    var __cardKickerColor:UIColor!
    var __cardDescriptionFont:UIFont!
    var __cardDescriptionColor:UIColor!
    var __cardActionButtonFont:UIFont!
    var __cardBackgroundColor:UIColor!
    var __cardDropShadow:Bool!
    var __applicationKey:String?
    var __analytics:WCAnalytics?
    var __networkDelegateQueue:OperationQueue!
    
    
}
