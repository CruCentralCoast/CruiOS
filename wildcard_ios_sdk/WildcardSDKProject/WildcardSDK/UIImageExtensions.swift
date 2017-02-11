//
//  UIImageExtensions.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 1/18/15.
//
//

import Foundation

extension UIImage{
    class func loadFrameworkImage(_ name:String)->UIImage?{
        let image = UIImage(named: name, in: Bundle.wildcardSDKBundle(), compatibleWith: nil)
        return image
    }
}
