//
//  CardViewAction.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/6/15.
//
//

import Foundation

@objc
open class CardViewAction: NSObject{
    
    /// Any parameters for the card action. e.g. for a WCCardAction.ViewOnWeb, there is a url parameter
    open let parameters:NSDictionary?
    
    /// Action type. See WCCardAction
    open let type:WCCardAction
    
    /// Init
    public init(type:WCCardAction, parameters:NSDictionary?){
        self.type = type
        self.parameters = parameters
    }
}
