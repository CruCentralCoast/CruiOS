//
//  UIImageViewExtensions.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 5/2/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//  Credit to https://stackoverflow.com/questions/24231680/loading-downloading-image-from-url-on-swift
//

import UIKit

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        ImageManager.instance.fetch(url) { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    func downloadedFrom(link: String?, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let link = link, let url = URL(string: link) else { return }
        self.downloadedFrom(url: url, contentMode: mode)
    }
}
