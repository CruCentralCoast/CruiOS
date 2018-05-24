//
//  VideoResourceDetailVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class VideoResourceDetailVC: UIViewController {
    
    
    var resource: VideoResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let resource = self.resource {
            self.navigationItem.title = resource.title
        }
    }
    
//    on button press
//    
//    if let url = URL(string: videoResource.url) {
//        let player = AVPlayer(url: url)
//        let vcPlayer = AVPlayerViewController()
//        vcPlayer.player = player
//        self.present(vcPlayer, animated: true, completion: nil)
//    }
    
}
