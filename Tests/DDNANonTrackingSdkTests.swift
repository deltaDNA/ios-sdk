import XCTest
@testable import DeltaDNA

class DDNANonTrackingSdkTests: XCTestCase {
    var mockInstanceFactory: DDNAInstanceFactoryMock!
    var mockCollectService: DDNACollectServiceMock!
    var mockSdk: DDNASDKMock!
    var mockUserManager: DDNAUserManagerMock!
    var mockSettings: DDNASettings!
    var nonTrackingSdk: DDNANonTrackingSdk!
    var mockDelegate: DDNASDKDelegateMock!
    
    override func setUpWithError() throws {
        mockSdk = DDNASDKMock()
        mockCollectService = DDNACollectServiceMock()
        mockInstanceFactory = DDNAInstanceFactoryMock()
        mockUserManager = DDNAUserManagerMock()
        mockSettings = DDNASettings()
        
        mockInstanceFactory.fakeCollectService = mockCollectService
        mockSdk.settings = mockSettings
        nonTrackingSdk = DDNANonTrackingSdk(sdk: mockSdk, instanceFactory: mockInstanceFactory)
    }

    func test_sendsDdnaForgetMeEvent() throws {
        mockUserManager.doNotTrack = true
        mockUserManager.forgotten = false
        mockUserManager.advertisingId = "123-ASDF-456"
        mockSdk.platform = "test console"
        mockSdk.willReturnUserID = "user123"
        mockSdk.willReturnSessionID = "session123"
        mockSettings.httpRequestCollectTimeoutSeconds = 5
        mockSettings.httpRequestMaxTries = 2
        mockSettings.httpRequestRetryDelaySeconds = 30
        
        nonTrackingSdk.start(withNewPlayer: mockUserManager)
        
        XCTAssertEqual(mockCollectService.requestCalledCount, 1)
        
        let collectRequest: DDNACollectRequest? = mockCollectService.requestArgumentCalled
        XCTAssertNotNil(collectRequest)
        XCTAssertEqual(collectRequest?.eventCount, 1)
        XCTAssertEqual(collectRequest?.timeoutSeconds, 5)
        XCTAssertEqual(collectRequest?.retries, 2)
        XCTAssertEqual(collectRequest?.retryDelaySeconds, 30)
        
        guard let json: NSDictionary = NSDictionary(jsonString: collectRequest?.toJSON()),
              let eventsJson = json["eventList"] as? [Any],
              let eventJson = eventsJson[0] as? [String : Any],
              let eventParams = eventJson["eventParams"] as? [String : Any] else {
            return XCTFail()
        }
        
        XCTAssertNotNil(eventJson["eventUUID"])
        XCTAssertNotNil(eventJson["eventTimestamp"])
        XCTAssertEqual(eventJson["userID"] as? String, "user123")
        XCTAssertEqual(eventJson["sessionID"] as? String, "session123")
        XCTAssertEqual(eventJson["eventName"] as? String, "ddnaForgetMe")
        
        XCTAssertEqual(eventParams["platform"] as? String, "test console")
        XCTAssertEqual(eventParams["sdkVersion"] as? String, DDNA_SDK_VERSION)
        XCTAssertEqual(eventParams["ddnaAdvertisingId"] as? String, "123-ASDF-456")
    }

    func test_reportsSuccessfulSessionConfiguration() throws {
        mockDelegate = DDNASDKDelegateMock()
        mockSdk.delegate = mockDelegate
        
        nonTrackingSdk.start(withNewPlayer: mockUserManager)
        nonTrackingSdk.requestSessionConfiguration(mockUserManager)
        
        XCTAssertEqual(mockDelegate.didFailToConfigureSessionWithErrorCalledCount, 0)
        XCTAssertEqual(mockDelegate.didConfigureSessionCalledCount, 1)
        XCTAssertFalse(mockDelegate.didConfigureSessionCacheArgumentCalled!)
        XCTAssertEqual(mockDelegate.didFailToConfigureSessionWithErrorCalledCount, 0)
        XCTAssertEqual(mockDelegate.didPopulateImageMessageCacheCalledCount, 1)
    }
}
