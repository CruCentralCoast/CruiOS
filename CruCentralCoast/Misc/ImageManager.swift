//
//  ImageManager.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 8/3/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ImageManager {
    static let instance = ImageManager()
    
    private init() {}
}

extension ImageManager {
    func fetch(_ urlString: String, _ completion: ((UIImage)->Void)? = nil) {
        guard let url = URL(string: urlString) else {
            print("WARN: Could not convert string to url: \(urlString).")
            return
        }
        
        self.fetch(url, completion)
    }
    
    func fetch(_ url: URL?, _ completion: ((UIImage)->Void)? = nil) {
        guard let url = url else { return }
        
        // Get the image location in local storage
        let imageDiskLocation = self.diskLocationForImage(url)
        
        // Try to fetch the image from local storage
        if let image = self.fetchFromDisk(imageDiskLocation) {
            completion?(image)
            return
        }
        
        // Download the image and store it
        self.fetchFromNetwork(url) { image in
            do {
                try UIImagePNGRepresentation(image)!.write(to: imageDiskLocation)
            } catch {
                print("WARN: Failed to save image: \(error)")
            }
            completion?(image)
        }
    }
    
    private func fetchFromNetwork(_ url: URL, _ completion: ((UIImage)->Void)? = nil) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                print("WARN: Failed to download image from \(url.absoluteString): \(error?.localizedDescription ?? "")")
                return
            }
            completion?(image)
        }.resume()
    }
    
    private func fetchFromDisk(_ url: URL) -> UIImage? {
        if FileManager.default.fileExists(atPath: url.path),
            let imageData = try? Data(contentsOf: url),
            let image = UIImage(data: imageData) {
            return image
        }
        return nil
    }
    
    private func diskLocationForImage(_ url: URL) -> URL {
        let imageName = url.deletingPathExtension().path.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: ".", with: "_")
        let imagePath = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(imageName).png"
        let imageUrl = URL(fileURLWithPath: imagePath)
        return imageUrl
    }
}
