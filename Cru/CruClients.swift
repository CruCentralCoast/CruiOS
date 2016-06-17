//
//  File.swift
//  Cru
//
//  Created by Peter Godkin on 4/24/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation

class CruClients {
    
    private static var serverClient: ServerProtocol!
    private static var rideUtils: RideUtils!
    private static var eventUtils: EventUtils!
    private static var subscriptionManager: SubscriptionProtocol!
    
    private static let clientDispatchQueue = dispatch_queue_create("idunnowhat", DISPATCH_QUEUE_CONCURRENT)

    private static func synchronized(closure: Void->Void) {
        dispatch_sync(clientDispatchQueue) {
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
