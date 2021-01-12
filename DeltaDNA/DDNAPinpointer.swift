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

#if os(iOS)
@available(iOS 12.0, *)
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
    
    @objc public func createSignalTrackingSessionEvent() -> DDNAEvent {
        return createBaseSignalMappingEvent(eventName: "unitySignalSession")
    }
    
    @objc public func createSignalTrackingInstallEvent() -> DDNAEvent {
        return createBaseSignalMappingEvent(eventName: "unitySignalInstall")
    }
    
    @objc public func createSignalTrackingPurchaseEvent(
        realCurrencyAmount: NSNumber,
        realCurrencyType: NSString
    ) -> DDNAEvent {
        let signalEvent = createBaseSignalMappingEvent(eventName: "unitySignalPurchase")
        signalEvent.setParam(realCurrencyAmount, forKey: "realCurrencyAmount")
        signalEvent.setParam(realCurrencyType, forKey: "realCurrencyType")
        return signalEvent
    }
    
    // MARK: Data helper methods
    
    private func createBaseSignalMappingEvent(eventName: String) -> DDNAEvent {
        let appStoreId = DDNASDK.sharedInstance()?.appStoreId
        let developerId = DDNASDK.sharedInstance()?.appleDeveloperId
        
        let signalEvent = DDNAEvent(name: eventName)!
        
        signalEvent.setParam(getDeviceModel() as NSString?, forKey: "deviceName")
        signalEvent.setParam((NSLocale.current.regionCode ?? "ZZ") as NSString, forKey: "userCountry")
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
        signalEvent.setParam(appStoreId as NSString?, forKey: "appStoreID")
        signalEvent.setParam(Bundle.main.bundleIdentifier as NSString?, forKey: "appBundleID")
        
        signalEvent.setParam(false as NSObject, forKey: "privacyPermissionAds")
        signalEvent.setParam(false as NSObject, forKey: "privacyPermissionExternal")
        signalEvent.setParam(false as NSObject, forKey: "privacyPermissionGameExp")
        signalEvent.setParam(false as NSObject, forKey: "privacyPermissionProfiling")
        signalEvent.setParam("developer_consent" as NSString, forKey: "privacyPermissionMethod")
        
        signalEvent.setParam(self.networkType as NSString, forKey: "connectionType")
        signalEvent.setParam(developerId as NSString?, forKey: "appDeveloperID")
        return signalEvent
    }
    
    private func getDeviceModel() -> String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
    }
}
#endif
