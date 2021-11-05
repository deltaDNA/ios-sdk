import Foundation
import XCTest
@testable import DeltaDNA

class DDNAConsentTrackerTests: XCTestCase {
    var consentTracker: DDNAConsentTracker!
    var userDefaults: UserDefaults!
    var geoIPMock: GeoIpNetworkClientMock!
    
    override func setUp() {
        let userDefaultDomain = "com.deltadna.test.consenttracker"
        UserDefaults().removePersistentDomain(forName: userDefaultDomain)
        userDefaults = UserDefaults(suiteName: userDefaultDomain)
        
        geoIPMock = GeoIpNetworkClientMock()
        
        consentTracker = DDNAConsentTracker(userDefaults: userDefaults, geoIpNetworkClient: geoIPMock)
    }
    
    // MARK: isPiplConsentRequired
    
    func test_whenCheckingIfConsentIsRequired_noPreviousResponse_andGeoIpReturnsResponseNotInChina_consentIsNotRequired() {
        let expectationToCheck = expectation(description: "Waiting for callback to complete")
        
        geoIPMock.responseToReturn = GeoIpResponse(identifier: "gdpr", country: "uk", region: "scotland", ageGateLimit: 13)
        
        consentTracker.isPiplConsentRequired(callback: { isRequired, error in
            XCTAssertNil(error)
            XCTAssertFalse(isRequired)
            expectationToCheck.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: { error in
            if let error = error {
                XCTFail("\(error)")
            }
        })
    }
    
    func test_whenCheckingIfConsentIsRequired_noPreviousResponse_andGeoIpReturnsResponseInChina_consentIsRequired() {
        let expectationToCheck = expectation(description: "Waiting for callback to complete")
        geoIPMock.responseToReturn = GeoIpResponse(identifier: "pipl", country: "cn", region: "beijing", ageGateLimit: 13)
        
        consentTracker.isPiplConsentRequired(callback: { isRequired, error in
            XCTAssertNil(error)
            XCTAssertTrue(isRequired)
            expectationToCheck.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: { error in
            if let error = error {
                XCTFail("\(error)")
            }
        })
    }
    
    func test_whenCheckingIfConsentIsRequired_andNotBothPreviousResponseIsRecorded_andGeoIpReturnsResponseInChina_consentCheckIsRequired() {
        let expectationToCheck = expectation(description: "Waiting for callback to complete")
        geoIPMock.responseToReturn = GeoIpResponse(identifier: "pipl", country: "cn", region: "beijing", ageGateLimit: 13)
        userDefaults.set(ConsentStatus.consentGiven.rawValue, forKey: "ddnaPiplUseStatus")
        
        consentTracker.isPiplConsentRequired(callback: { isRequired, error in
            XCTAssertNil(error)
            XCTAssertTrue(isRequired)
            expectationToCheck.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: { error in
            if let error = error {
                XCTFail("\(error)")
            }
        })
    }
    
    func test_whenCheckingIfConsentIsRequired_andBothPreviousResponseIsRecorded_consentCheckIsNotRequired() {
        let expectationToCheck = expectation(description: "Waiting for callback to complete")
        geoIPMock.responseToReturn = GeoIpResponse(identifier: "pipl", country: "cn", region: "beijing", ageGateLimit: 13)
        userDefaults.set(ConsentStatus.consentGiven.rawValue, forKey: "ddnaPiplUseStatus")
        userDefaults.set(ConsentStatus.consentGiven.rawValue, forKey: "ddnaPiplExportStatus")
        
        consentTracker.isPiplConsentRequired(callback: { isRequired, error in
            XCTAssertNil(error)
            XCTAssertTrue(isRequired)
            expectationToCheck.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: { error in
            if let error = error {
                XCTFail("\(error)")
            }
        })
    }

    // MARK: hasCheckedForConsent
    
    func test_whenCheckingIfConsentHasBeenChecked_andNoConsentsAreChecked_returnsFalse() {
        consentTracker.piplUseStatus = .unknown
        consentTracker.piplExportStatus = .unknown
        
        XCTAssertFalse(consentTracker.hasCheckedForConsent())
    }
    
    func test_whenCheckingIfConsentHasBeenChecked_andExportIsNotChecked_returnsFalse() {
        consentTracker.piplUseStatus = .notRequired
        consentTracker.piplExportStatus = .unknown
        
        XCTAssertFalse(consentTracker.hasCheckedForConsent())
    }
    
    func test_whenCheckingIfConsentHasBeenChecked_andStatusIsNotChecked_returnsFalse() {
        consentTracker.piplUseStatus = .unknown
        consentTracker.piplExportStatus = .notRequired
        
        XCTAssertFalse(consentTracker.hasCheckedForConsent())
    }
    
    func test_whenCheckingIfConsentHasBeenChecked_andBothHaveBeenChecked_returnsTrue() {
        consentTracker.piplUseStatus = .consentGiven
        consentTracker.piplExportStatus = .consentDenied
        
        XCTAssertTrue(consentTracker.hasCheckedForConsent())
    }
    
    // MARK: setPiplUseConsent
    
    func test_whenSettingUserConsent_andConsentIsProvided_theCorrectConsentIsSaved() {
        consentTracker.setPiplUseConsent(true)
        
        XCTAssertEqual(ConsentStatus.consentGiven.rawValue, userDefaults.integer(forKey: "ddnaPiplUseStatus"))
        XCTAssertEqual(ConsentStatus.consentGiven, consentTracker.piplUseStatus)
    }
    
    func test_whenSettingUserConsent_andConsentIsNotProvided_theCorrectConsentIsSaved() {
        consentTracker.setPiplUseConsent(false)
        
        XCTAssertEqual(ConsentStatus.consentDenied.rawValue, userDefaults.integer(forKey: "ddnaPiplUseStatus"))
        XCTAssertEqual(ConsentStatus.consentDenied, consentTracker.piplUseStatus)
    }
    
    // MARK: setPiplExportConsent
    
    func test_whenSettingUserExportConsent_andConsentIsProvided_theCorrectConsentIsSaved() {
        consentTracker.setPiplExportConsent(true)
        
        XCTAssertEqual(ConsentStatus.consentGiven.rawValue, userDefaults.integer(forKey: "ddnaPiplExportStatus"))
        XCTAssertEqual(ConsentStatus.consentGiven, consentTracker.piplExportStatus)
    }
    
    func test_whenSettingUserExportConsent_andConsentIsNotProvided_theCorrectConsentIsSaved() {
        consentTracker.setPiplExportConsent(false)
        
        XCTAssertEqual(ConsentStatus.consentDenied.rawValue, userDefaults.integer(forKey: "ddnaPiplExportStatus"))
        XCTAssertEqual(ConsentStatus.consentDenied, consentTracker.piplExportStatus)
    }
    
    // MARK: allConsentsAreMet
    
    func test_whenCheckingAllConsentsAreMet_IfNoneAreMet_returnsFalse() {
        consentTracker.piplExportStatus = .consentDenied
        consentTracker.piplUseStatus = .unknown
        
        XCTAssertFalse(consentTracker.allConsentsAreMet())
    }
    
    func test_whenCheckingAllConsentsAreMet_IfSomeAreMet_returnsFalse() {
        consentTracker.piplExportStatus = .consentGiven
        consentTracker.piplUseStatus = .unknown
        
        XCTAssertFalse(consentTracker.allConsentsAreMet())
    }
    
    func test_whenCheckingAllConsentsAreMet_IfAllAreMet_returnsTrue() {
        consentTracker.piplExportStatus = .consentGiven
        consentTracker.piplUseStatus = .consentGiven
        
        XCTAssertTrue(consentTracker.allConsentsAreMet())
    }
}
