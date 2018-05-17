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
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        self.downloadedFrom(url: url, contentMode: mode)
    }
}
