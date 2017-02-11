//
//  NSBundleExtensions.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation

public extension Bundle{
    /// Gets a reference to the WildcardSDK Bundle
    public class func wildcardSDKBundle()->Bundle{
        let bundle = Bundle(identifier: "com.trywildcard.WildcardSDK")
        return bundle!
    }
}
