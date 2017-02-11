//
//  RedirectView.swift
//  WildcardSDKProject
//
//  Created by David Xiang on 3/9/15.
//
//

import Foundation

class PassthroughView: UIView {
    
    var otherView:UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
    {
        // pass through touches
        let hitView = super.hitTest(point, with:event)
        if(hitView == self){
            return otherView
        }
        return hitView
    }
    
}
