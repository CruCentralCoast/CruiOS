//
//  PlaybackSlider.swift
//  Cru
//
//  Created by Erica Solum on 3/8/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import QuartzCore

class PlaybackSlider: UISlider {
    var trackLayer = CALayer()
    var gradientLayer: CAGradientLayer!
    var lowerThumbLayer = CALayer()
    var upperThumbLayer = CALayer()
    var grayLayer = CALayer()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //Override the method to make the track taller
    open override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var result = super.trackRect(forBounds: bounds)
        result.size.height = 10
        return result
    }
    
    func setSliderWithGradientColors(color: UIColor, color2: UIColor) {
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        
        let view = self.subviews[0]
        view.layer.cornerRadius = CGFloat(integerLiteral: 0)
        let minTrackImageView = self.subviews[1] as! UIImageView
        
        var rect = minTrackImageView.frame
        gradientLayer.frame = rect
        minTrackImageView.layer.insertSublayer(gradientLayer, at: 0)
        //minTrackImageView.layer.replaceSublayer(minTrackImageView.layer, with: gradientLayer.)
    }

}
