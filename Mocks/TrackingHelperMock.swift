import AppTrackingTransparency
import AdSupport
@testable import DeltaDNA

internal class TrackingHelperMock: TrackingHelperProtocol {
    var idfaPresentReturns: Bool = false
    var trackingAuthorizationStatus: NSString = "01234567-8901-2345-6789-012345678901"
    var checkNetworkTypeReturns: NetworkType = .unknown
    
    @available(iOS 14.0, *)
    lazy var status: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    @available(iOS 14, *)
    func getTrackingStatus() -> ATTrackingManager.AuthorizationStatus {
        return status
    }
    
    func isIdfaPresent() -> Bool {
        return idfaPresentReturns
    }
    
    func getTrackingAuthorizationStatus() -> NSString {
        return trackingAuthorizationStatus
    }
    
    @available(iOS 12, *)
    func checkNetworkType(path: NWPathProtocol) -> NetworkType {
        return checkNetworkTypeReturns
    }
}
