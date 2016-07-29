//
//  Notification.swift
//  Cru
//
//  Created by Erica Solum on 7/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class Notification: NSObject, NSCoding {
    var content: String
    var title: String
    var dateReceived: NSDate
    
    init?(title: String, content: String, dateReceived: NSDate) {
        self.title = title
        self.content = content
        self.dateReceived = dateReceived
        
        super.init()
        
        if title.isEmpty || content.isEmpty {
            return nil
        }
    }
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("notifications")
    
    // Mark: Types
    struct PropertyKey {
        static let titleKey = "title"
        static let contentKey = "content"
        static let dateKey = "date"
    }
    
    // Mark: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(content, forKey: PropertyKey.contentKey)
        aCoder.encodeObject(dateReceived, forKey: PropertyKey.dateKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let content = aDecoder.decodeObjectForKey(PropertyKey.contentKey) as! String
        let dateReceived = aDecoder.decodeObjectForKey(PropertyKey.dateKey) as! NSDate
        
        self.init(title: title, content: content, dateReceived: dateReceived)
    }
}
