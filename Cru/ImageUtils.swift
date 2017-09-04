//
//  ImageUtils.swift
//  Cru
//
//  Created by Erica Solum on 8/23/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import AlamofireImage

class ImageUtils {

    var serverClient: ServerProtocol!
    private var imageDownloader: ImageDownloader
    
    convenience init() {
        self.init(serverProtocol: CruClients.getServerClient())
    }
    
    init(serverProtocol: ServerProtocol) {
        serverClient = serverProtocol
        imageDownloader = ImageDownloader()
    }
    
    func getImageDownloader() -> ImageDownloader {
        return imageDownloader
    }
    
}
