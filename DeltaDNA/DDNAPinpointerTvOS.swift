//
//  DDNAPinpointerTvOSPlaceholder.swift
//  DeltaDNA tvOS
//
//  Created by Tim Hull on 29/10/2020.
//

import Foundation

// Note: This is a placeholder in order to satisfy Cocoapod's tvOS build.
// We don't yet support Pinpointer on tvOS.
#if os(tvOS)
@available(tvOS 14.0, *)
public class DDNAPinpointer: NSObject {
    @objc public static let shared = DDNAPinpointer()
    
    // MARK: Event methods
    
    @objc public func createSignalTrackingSessionEvent(developerId: NSString) -> DDNAEvent {
        let signalEvent = DDNAEvent(name: "unitySignalSession")!
        return signalEvent
    }
    
    @objc public func createSignalTrackingPurchaseEvent(
        realCurrencyAmount: NSNumber,
        realCurrencyType: NSString,
        developerId: NSString
    ) -> DDNAEvent {
        let signalEvent = DDNAEvent(name: "unitySignalPurchase")!
        return signalEvent
    }
}
#endif
