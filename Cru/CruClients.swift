//
//  File.swift
//  Cru
//
//  Created by Peter Godkin on 4/24/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class CruClients {
    
    fileprivate static var serverClient: ServerProtocol!
    fileprivate static var rideUtils: RideUtils!
    fileprivate static var imageUtils: ImageUtils!
    fileprivate static var eventUtils: EventUtils!
    fileprivate static var communityGroupUtils: CommunityGroupUtils!
    fileprivate static var subscriptionManager: SubscriptionProtocol!
    
    fileprivate static let clientDispatchQueue = DispatchQueue(label: "idunnowhat", attributes: DispatchQueue.Attributes.concurrent)

    fileprivate static func synchronized(_ closure: (Void)->Void) {
        clientDispatchQueue.sync {
            closure()
        }
    }
    
    static func getServerClient() -> ServerProtocol {
        synchronized() {
            if (serverClient == nil) {
                serverClient = KeystoneClient()
            }
        }
        return serverClient
    }
    
    static func getRideUtils() -> RideUtils {
        synchronized() {
            if (rideUtils == nil) {
                rideUtils = RideUtils()
            }
        }
        return rideUtils
    }
    
    static func getEventUtils() -> EventUtils {
        synchronized() {
            if (eventUtils == nil) {
                eventUtils = EventUtils()
            }
        }
        return eventUtils
    }
    
    static func getCommunityGroupUtils() -> CommunityGroupUtils {
        synchronized() {
            if (communityGroupUtils == nil) {
                communityGroupUtils = CommunityGroupUtils()
            }
        }
        return communityGroupUtils
    }
    
    static func getImageUtils() -> ImageUtils {
        synchronized() {
            if (imageUtils == nil) {
                imageUtils = ImageUtils()
            }
        }
        return imageUtils
    }
    
    static func getSubscriptionManager() -> SubscriptionProtocol {
        synchronized() {
            if (subscriptionManager == nil) {
                if (Config.simulatorMode) {
                    subscriptionManager = FakeSubscriptionManager()
                } else {
                    subscriptionManager = SubscriptionManager()
                }
            }
        }
        return subscriptionManager
    }
}
