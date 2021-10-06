import AppTrackingTransparency
import AdSupport

internal protocol TrackingHelperProtocol {
    func isIdfaPresent () -> Bool
    func getTrackingAuthorizationStatus() -> NSString
    @available(iOS 14, *) func getTrackingStatus() -> ATTrackingManager.AuthorizationStatus
    @available(iOS 12, *) func checkNetworkType(path: NWPathProtocol) -> NetworkType
}


internal class TrackingHelper: TrackingHelperProtocol {
    private let asIdentifierManager: ASIdentifierManager
    
    init(asIdentifierManager: ASIdentifierManager = ASIdentifierManager.shared()) {
        self.asIdentifierManager = asIdentifierManager
    }
    
    @available(iOS 14, *)
    func getTrackingStatus() -> ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
    
    func isIdfaPresent() -> Bool {
        if #available(iOS 14, *) {
            return ATTrackingManager.trackingAuthorizationStatus == .authorized
        } else {
            return asIdentifierManager.isAdvertisingTrackingEnabled
        }
    }
    
    func getTrackingAuthorizationStatus() -> NSString {
        return asIdentifierManager.advertisingIdentifier.uuidString as NSString
    }
    
    @available(iOS 12, *)
    func checkNetworkType(path: NWPathProtocol) -> NetworkType {
        if path.status == .satisfied {
            return path.isExpensive ? .celullar : .wifi
        }
        
        return .unknown
    }
}

public enum NetworkType: String, CaseIterable {
    case unknown
    case celullar
    case wifi
}
