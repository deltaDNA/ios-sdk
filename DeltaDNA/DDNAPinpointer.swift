//
// Copyright (c) 2020 deltaDNA Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import Network
import AppTrackingTransparency
import AdSupport

public class DDNAPinpointer: NSObject {
    static let wifiIdentifier = "wifi"
    static let cellularIdentifier = "cellular"
    
    // MARK: Event methods
    
    @objc public static func createSignalTrackingSessionEvent(developerId: NSString) -> DDNAEvent {
        let signalEvent = DDNAEvent(name: "unitySignalTrackingSession")!
        signalEvent.setParam(UIDevice.current.model as NSString, forKey: "deviceType")
        signalEvent.setParam((NSLocale.current.regionCode ?? "ZZ") as NSString, forKey: "userCountry")
        signalEvent.setParam((NSLocale.current.languageCode ?? "zz") as NSString, forKey: "deviceLanguage")
        signalEvent.setParam(UIDevice.current.identifierForVendor?.uuidString as NSString?, forKey: "idfv")
        
        var idfaIsPresent: Bool = false
        if #available(iOS 14, *) {
            idfaIsPresent = ATTrackingManager.trackingAuthorizationStatus == .authorized
        } else {
            idfaIsPresent = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
        if (idfaIsPresent) {
            signalEvent.setParam(ASIdentifierManager.shared().advertisingIdentifier.uuidString as NSString, forKey: "idfa");
        }
        signalEvent.setParam(idfaIsPresent as NSObject, forKey: "limitedAdTracking")
        signalEvent.setParam(Bundle.main.bundleIdentifier as NSString?, forKey: "appStoreId")
        signalEvent.setParam(idfaIsPresent as NSObject, forKey: "privacyPermissionAds")
        signalEvent.setParam(true as NSObject, forKey: "privacyPermissionExternal")
        signalEvent.setParam(true as NSObject, forKey: "privacyPermissionGameExp")
        signalEvent.setParam(true as NSObject, forKey: "privacyPermissionProfiling")
        
        let networkType: NSString
        if #available(iOS 12.0, *) {
            networkType = getNetworkType()
        } else {
            networkType = "unknown"
        }
        signalEvent.setParam(networkType, forKey: "connectionType")
        if let ipAddress = getIPAddress(usingInterface: networkType) {
            signalEvent.setParam(ipAddress, forKey: "ipAddress")
        }
        signalEvent.setParam(developerId, forKey: "appDeveloperID")
        
        return signalEvent
    }
    
    @objc public static func createSignalTrackingPurchaseEvent(
        realCurrencyAmount: NSNumber,
        realCurrencyType: NSString,
        developerId: NSString
    ) -> DDNAEvent {
        // For now, this event and the one for the session share much of the same
        // content, so we can reuse the above method to get us started here too.
        let signalEvent = createSignalTrackingSessionEvent(developerId: developerId)
        signalEvent.setParam(realCurrencyAmount, forKey: "realCurrencyAmount")
        signalEvent.setParam(realCurrencyType, forKey: "realCurrencyType")
        return signalEvent
    }
    
    @objc public static func createSignalTrackingAdRevenueEvent(
        realCurrencyAmount: NSNumber,
        realCurrencyType: NSString,
        developerId: NSString
    ) -> DDNAEvent {
        // For now, this event and the one for purchases have the same content, so
        // to avoid duplication we can reuse that method verbatim.
        return createSignalTrackingPurchaseEvent(
            realCurrencyAmount: realCurrencyAmount,
            realCurrencyType: realCurrencyType,
            developerId: developerId
        )
    }
    
    // MARK: Data helper methods
    
    @available(iOS 12.0, *)
    private static func getNetworkType() -> NSString {
        // TODO: Should we just create the network monitor once and leave it running on
        // a background thread? That way we always have up to date data cached, but at
        // a small performance hit?
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue.global(qos: .default))
        var networkType = "unknown"
        if monitor.currentPath.usesInterfaceType(.wifi) {
            networkType = wifiIdentifier
        } else if monitor.currentPath.usesInterfaceType(.cellular) {
            networkType = cellularIdentifier
        }
        monitor.cancel()
        return networkType as NSString
    }
    
    // NOTE: This method gets the *local* ip address of the interface requested. If a
    // public IP address is required this will need to be gathered from a network request.
    // It uses an Apple inbuilt C library, which needs to be included in the main app header.
    private static func getIPAddress(usingInterface requiredInterfaceIdentifier: NSString) -> NSString? {
        let wifiInterfaceName = "en0"
        let cellularInterfaceName = "pdp_ip0"
        
        var address : String?

        var interfaceAddressLinkedList : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddressLinkedList) == 0 else { return nil }
        guard let firstAddress = interfaceAddressLinkedList else { return nil }

        for interfacePointer in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let interface = interfacePointer.pointee
            let interfaceAddressFamily = interface.ifa_addr.pointee.sa_family
            if interfaceAddressFamily == UInt8(AF_INET) || interfaceAddressFamily == UInt8(AF_INET6) {
                let interfaceName = String(cString: interface.ifa_name)
                let requiredInterfaceName = (requiredInterfaceIdentifier as String) == wifiIdentifier
                    ? wifiInterfaceName
                    : cellularInterfaceName
                
                if interfaceName == requiredInterfaceName {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(
                        interface.ifa_addr,
                        socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname,
                        socklen_t(hostname.count),
                        nil,
                        socklen_t(0),
                        NI_NUMERICHOST
                    )
                    address = String(cString: hostname)
                    break
                }
            }
        }
        freeifaddrs(interfaceAddressLinkedList)

        return address as NSString?
    }
}
