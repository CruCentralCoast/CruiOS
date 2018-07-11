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
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { completion(nil); return }
            completion(image)
        }.resume()
    }
    static func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, completion: completion)
    }
}
