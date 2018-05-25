//
//  AudioDetailVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/24/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import AVKit

class AudioResourceDetailVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var resource: AudioResource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = resource?.title
        self.titleLabel.text = resource?.title
        self.authorLabel.text = "by \(resource?.author ?? "Unknown")"
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if let videoResourceString = self.resource?.url, let url = URL(string: videoResourceString) {
            let player = AVPlayer(url: url)
            let vcPlayer = AVPlayerViewController()
            vcPlayer.player = player
            self.present(vcPlayer, animated: true, completion: nil)
        }
    }
}
