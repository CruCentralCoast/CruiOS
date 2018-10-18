//
//  UIImageExtensions.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 5/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

extension UIImage {
    static func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, completion: @escaping (UIImage?) -> Void) {
        ImageManager.instance.fetch(url) { image in
            completion(image)
        }
    }
    static func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, completion: completion)
    }
}
