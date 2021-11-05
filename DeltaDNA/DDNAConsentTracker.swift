import Foundation

@objc public enum ConsentStatus: Int {
    case unknown = 0, notRequired, requiredButUnchecked, consentGiven, consentDenied
}

@objc public class DDNAConsentTracker: NSObject {
    @objc public var piplUseStatus: ConsentStatus
    @objc public var piplExportStatus: ConsentStatus
    
    private let userDefaultsInstance: UserDefaults
    private let geoIPNetworkClient: GeoIpNetworkClientProtocol
    
    private let piplUseStatusKey = "ddnaPiplUseStatus"
    private let piplExportStatusKey = "ddnaPiplExportStatus"
    
    @objc public convenience override init() {
        self.init(userDefaults: UserDefaults.standard, geoIpNetworkClient: GeoIpNetworkClient())
    }
    
    init(userDefaults: UserDefaults, geoIpNetworkClient: GeoIpNetworkClientProtocol) {
        self.userDefaultsInstance = userDefaults
        self.geoIPNetworkClient = geoIpNetworkClient
        
        piplUseStatus = ConsentStatus(rawValue: userDefaultsInstance.integer(forKey: piplUseStatusKey)) ?? .unknown
        piplExportStatus = ConsentStatus(rawValue: userDefaultsInstance.integer(forKey: piplExportStatusKey)) ?? .unknown
        
        super.init()
    }
    
    @objc public func hasCheckedForConsent() -> Bool {
        let checkedConsentStatuses: [ConsentStatus] = [.notRequired, .consentGiven, .consentDenied]
        return checkedConsentStatuses.contains(piplUseStatus)
            && checkedConsentStatuses.contains(piplExportStatus)
    }
    
    @objc public func isPiplConsentRequired(callback: @escaping (Bool, Error?) -> ()) {
        if hasCheckedForConsent() {
            callback(false, nil)
            return
        }
        geoIPNetworkClient.fetchGeoIpResponse { response, error in
            if let error = error {
                NSLog("Unable to check for the required consents to use DeltaDNA in this region because \(error.localizedDescription).")
                callback(false, error)
                return
            }
            if let response = response {
                let isConsentNeeded = response.identifier == "pipl"
                let consentStatus = isConsentNeeded ? ConsentStatus.requiredButUnchecked : ConsentStatus.notRequired
                self.piplUseStatus = consentStatus
                self.piplExportStatus = consentStatus
                callback(isConsentNeeded, nil)
            } else {
                NSLog("Unable to check for the required consents to use DeltaDNA in this region because the response was empty.")
                callback(false, URLError(.badServerResponse))
            }
        }
    }
    
    @objc public func setPiplUseConsent(_ isConsentGiven: Bool) {
        piplUseStatus = isConsentGiven ? .consentGiven : .consentDenied
        userDefaultsInstance.set(piplUseStatus.rawValue, forKey: piplUseStatusKey)
    }
    
    @objc public func setPiplExportConsent(_ isConsentGiven: Bool) {
        piplExportStatus = isConsentGiven ? .consentGiven : .consentDenied
        userDefaultsInstance.set(piplExportStatus.rawValue, forKey: piplExportStatusKey)
    }
    
    @objc public func allConsentsAreMet() -> Bool {
        return (piplUseStatus == .consentGiven || piplUseStatus == .notRequired)
            && (piplExportStatus == .consentGiven || piplExportStatus == .notRequired)
    }
    
    @objc public func isConsentDenied() -> Bool {
        return piplUseStatus == .consentDenied || piplExportStatus == .consentDenied
    }
}
