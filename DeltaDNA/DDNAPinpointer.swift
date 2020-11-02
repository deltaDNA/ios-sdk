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

/*
 WARNING: If you are updating the contract of the APIs in this file,
 remember to update/regenerate DeltaDNA-Swift.h too.
 */

import Foundation
import Network
import AppTrackingTransparency
import AdSupport

@available(iOS 12.0, tvOS 14.0, *)
public class DDNAPinpointer: NSObject {
    @objc public static let shared = DDNAPinpointer()
    
    let wifiIdentifier = "wifi"
    let cellularIdentifier = "cellular"
    var networkType = "unknown"
    var monitor: NWPathMonitor? = nil
    
    override init() {
        super.init()
        self.monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.networkType = path.isExpensive ? self.cellularIdentifier : self.wifiIdentifier
            }
        }
        monitor?.start(queue: DispatchQueue.global(qos: .background))
    }
    
    deinit {
        self.monitor?.cancel()
    }
    
    // MARK: Event methods
    
    @objc public func createSignalTrackingSessionEvent(developerId: NSString) -> DDNAEvent {
        let signalEvent = createBaseSignalMappingEvent(developerId: developerId, eventName: "unitySignalSession")
        return signalEvent
    }
    
    @objc public func createSignalTrackingPurchaseEvent(
        realCurrencyAmount: NSNumber,
        realCurrencyType: NSString,
        developerId: NSString
    ) -> DDNAEvent {
        let signalEvent = createBaseSignalMappingEvent(developerId: developerId, eventName: "unitySignalPurchase")
        signalEvent.setParam(realCurrencyAmount, forKey: "realCurrencyAmount")
        signalEvent.setParam(realCurrencyType, forKey: "realCurrencyType")
        return signalEvent
    }
    
    // MARK: Data helper methods
    
    private func createBaseSignalMappingEvent(developerId: NSString, eventName: String) -> DDNAEvent {
        let signalEvent = DDNAEvent(name: eventName)!
        signalEvent.setParam(UIDevice.current.model as NSString, forKey: "deviceName")
        signalEvent.setParam((NSLocale.current.regionCode ?? "ZZ") as NSString, forKey: "userCountry")
        signalEvent.setParam((NSLocale.current.languageCode ?? "zz") as NSString, forKey: "deviceLanguage")
        signalEvent.setParam(UIDevice.current.identifierForVendor?.uuidString as NSString?, forKey: "idfv")
        
        var idfaIsPresent: Bool = false
        if #available(iOS 14, *) {
            idfaIsPresent = ATTrackingManager.trackingAuthorizationStatus == .authorized
            signalEvent.setParam(ATTrackingManager.trackingAuthorizationStatus.rawValue as NSNumber, forKey: "attTrackingStatus")
        } else {
            idfaIsPresent = ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
        if (idfaIsPresent) {
            signalEvent.setParam(ASIdentifierManager.shared().advertisingIdentifier.uuidString as NSString, forKey: "idfa");
        }
        signalEvent.setParam(!idfaIsPresent as NSObject, forKey: "limitedAdTracking")
        signalEvent.setParam(Bundle.main.bundleIdentifier as NSString?, forKey: "appStoreId")
        signalEvent.setParam(idfaIsPresent as NSObject, forKey: "privacyPermissionAds")
        signalEvent.setParam(true as NSObject, forKey: "privacyPermissionExternal")
        signalEvent.setParam(true as NSObject, forKey: "privacyPermissionGameExp")
        
        signalEvent.setParam(self.networkType as NSString, forKey: "connectionType")
        if let ipAddress = getIPAddress(usingInterface: networkType) {
            signalEvent.setParam(ipAddress, forKey: "ipAddress")
        }
        signalEvent.setParam(developerId, forKey: "appDeveloperID")
        return signalEvent
    }
    
    // NOTE: This method gets the *local* ip address of the interface requested. If a
    // public IP address is required this will need to be gathered from a network request.
    // It uses an Apple inbuilt C library, which needs to be included in the main app header.
    private func getIPAddress(usingInterface requiredInterfaceIdentifier: String) -> NSString? {
        let wifiInterfaceName = "en0"
        let cellularInterfaceName = "pdp_ip0"
        
        var address : String?

        var interfaceAddressLinkedList : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddressLinkedList) == 0 else { return nil }
        guard let firstAddress = interfaceAddressLinkedList else { return nil }

        for interfacePointer in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let interface = interfacePointer.pointee
            let interfaceAddressFamily = interface.ifa_addr.pointee.sa_family
            if interfaceAddressFamily == UInt8(AF_INET) {
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
