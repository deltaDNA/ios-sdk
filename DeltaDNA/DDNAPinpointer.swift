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

#if os(iOS)
@available(iOS 12.0, *)
public class DDNAPinpointer: NSObject {
    @objc public static let shared = DDNAPinpointer()
    
    var networkType: NetworkType = .unknown
    var monitor: NWPathMonitorProtocol
    var ddnasdk: DDNASDK
    var trackingHelper: TrackingHelperProtocol
    
    internal init(ddnasdk: DDNASDK, trackingHelper: TrackingHelperProtocol, monitor: NWPathMonitorProtocol) {
        self.ddnasdk = ddnasdk
        self.trackingHelper = trackingHelper
        self.monitor = monitor
        super.init()
        self.setUpMonitoring()
    }
    
    override init() {
        self.ddnasdk = DDNASDK.sharedInstance()
        self.trackingHelper = TrackingHelper()
        self.monitor = NWPathMonitor()
        super.init()
        self.setUpMonitoring()
    }
    
    deinit {
        monitor.cancel()
    }
    
    private func setUpMonitoring() {
        self.monitor.pathUpdateHandler = { path in
            self.networkType = self.trackingHelper.checkNetworkType(path: path)
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    // MARK: Event methods
    
    @objc public func createSignalTrackingSessionEvent() -> DDNAEvent {
        return createBaseSignalMappingEvent(eventName: PinpointerEventName.session)
    }
    
    @objc public func createSignalTrackingInstallEvent() -> DDNAEvent {
        return createBaseSignalMappingEvent(eventName: PinpointerEventName.install)
    }
    
    @objc public func createSignalTrackingPurchaseEvent(
        realCurrencyAmount: NSNumber,
        realCurrencyType: NSString,
        transactionID: NSString
    ) -> DDNAEvent {
        let signalEvent = createBaseSignalMappingEvent(eventName: PinpointerEventName.purchase)
        signalEvent.setParam(realCurrencyAmount, forKey: PinpointerEventKey.realCurrencyAmount.rawValue)
        signalEvent.setParam(realCurrencyType, forKey: PinpointerEventKey.realCurrencyType.rawValue)
        signalEvent.setParam(transactionID, forKey: PinpointerEventKey.transactionID.rawValue)
        return signalEvent
    }
    
    // MARK: Data helper methods
    
    private func createBaseSignalMappingEvent(eventName: PinpointerEventName) -> DDNAEvent {
        
        let signalEvent = DDNAEvent(name: eventName.rawValue)!
        
        signalEvent.setParam(getDeviceModel() as NSString?, forKey: PinpointerEventKey.deviceName.rawValue)
        signalEvent.setParam((NSLocale.current.regionCode ?? "ZZ") as NSString, forKey: PinpointerEventKey.userCountry.rawValue)
        signalEvent.setParam(UIDevice.current.identifierForVendor?.uuidString as NSString?, forKey: PinpointerEventKey.idfv.rawValue)
        
        let idfaIsPresent: Bool = trackingHelper.isIdfaPresent()
        
        if #available(iOS 14, *) {
            signalEvent.setParam(trackingHelper.getTrackingStatus().rawValue as NSNumber, forKey: PinpointerEventKey.attTrackingStatus.rawValue)
        }
        
        if (idfaIsPresent) {
            signalEvent.setParam(trackingHelper.getTrackingAuthorizationStatus(), forKey: PinpointerEventKey.idfa.rawValue);
        }
        
        signalEvent.setParam(!idfaIsPresent as NSObject, forKey: PinpointerEventKey.limitedAdTracking.rawValue)
        
        signalEvent.setParam(ddnasdk.appStoreId as NSString?, forKey: PinpointerEventKey.appStoreID.rawValue)
        signalEvent.setParam(ddnasdk.appleDeveloperId as NSString?, forKey: PinpointerEventKey.appDeveloperID.rawValue)
        
        signalEvent.setParam(Bundle.main.bundleIdentifier as NSString?, forKey: PinpointerEventKey.appBundleID.rawValue)
        
        signalEvent.setParam(false as NSObject, forKey: PinpointerEventKey.privacyPermissionAds.rawValue)
        signalEvent.setParam(false as NSObject, forKey: PinpointerEventKey.privacyPermissionExternal.rawValue)
        signalEvent.setParam(false as NSObject, forKey: PinpointerEventKey.privacyPermissionGameExp.rawValue)
        signalEvent.setParam(false as NSObject, forKey: PinpointerEventKey.privacyPermissionProfiling.rawValue)
        signalEvent.setParam("developer_consent" as NSString, forKey: PinpointerEventKey.privacyPermissionMethod.rawValue)
        
        signalEvent.setParam(self.networkType.rawValue as NSString, forKey: PinpointerEventKey.connectionType.rawValue)
        
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
