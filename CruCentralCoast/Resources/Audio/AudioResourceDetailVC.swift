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
    var audioResourceDelegate: AudioResourceDelegate?
    var audioPlayer: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.resource?.title
        self.titleLabel.text = self.resource?.title
        self.authorLabel.text = "by \(self.resource?.author ?? "Unknown")"
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        if let audioResource = self.resource, let url = URL(string: audioResource.url) {
            self.audioResourceDelegate?.playAudioFromURL(url: url, title: audioResource.title)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
