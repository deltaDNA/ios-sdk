import XCTest
import Network
@testable import DeltaDNA

@available(iOS 12.0, *)
class DDNAPinpointerTests: XCTestCase {

    var ddnaPinpointer: DDNAPinpointer!
    var mockDDNASDK: DDNASDKMock!
    var trackingHelperMock: TrackingHelperMock!
    var mockNWPathMonitor: NWPathMonitorMock!
    
    override func setUp() {
        mockDDNASDK = DDNASDKMock()
        trackingHelperMock = TrackingHelperMock()
        mockDDNASDK.appStoreId = "TestAppStoreId"
        mockDDNASDK.appleDeveloperId = "TestAppleDeveloperId"
        mockNWPathMonitor = NWPathMonitorMock()
        ddnaPinpointer = DDNAPinpointer(ddnasdk: mockDDNASDK, trackingHelper: trackingHelperMock, monitor: mockNWPathMonitor)
    }
    
    func testSetupPathMonitoring() throws {
        XCTAssertTrue(mockNWPathMonitor.startCalled)
        XCTAssertEqual(mockNWPathMonitor.startQueue, DispatchQueue.global(qos: .background))
        XCTAssertFalse(mockNWPathMonitor.cancelCalled)
    }
    
    func testSignalTrackingSessionNetworkTypes() {
        for networkType in NetworkType.allCases {
            trackingHelperMock.checkNetworkTypeReturns = networkType
            ddnaPinpointer.monitor.pathUpdateHandler!(fetchPath())
            let signalTrackingSessionEvent: DDNAEvent = ddnaPinpointer.createSignalTrackingSessionEvent()
            let signalTrackingSessionParameters = signalTrackingSessionEvent.dictionary()["eventParams"] as! [String : Any]
            XCTAssertEqual(networkType.rawValue, signalTrackingSessionParameters[PinpointerEventKey.connectionType.rawValue] as? String)
        }
    }
    
    func testSignalTrackingInstallNetworkTypes() {
        for networkType in NetworkType.allCases {
            trackingHelperMock.checkNetworkTypeReturns = networkType
            ddnaPinpointer.monitor.pathUpdateHandler!(fetchPath())
            let signalTrackingInstallEvent: DDNAEvent = ddnaPinpointer.createSignalTrackingInstallEvent()
            let signalTrackingInstallParameters = signalTrackingInstallEvent.dictionary()["eventParams"] as! [String : Any]
            XCTAssertEqual(networkType.rawValue, signalTrackingInstallParameters[PinpointerEventKey.connectionType.rawValue] as? String)
        }
    }
    
    func testSignalTrackingPurchaseNetworkTypes() {
        for networkType in NetworkType.allCases {
            trackingHelperMock.checkNetworkTypeReturns = networkType
            ddnaPinpointer.monitor.pathUpdateHandler!(fetchPath())
            let signalTrackingSessionEvent: DDNAEvent = ddnaPinpointer.createSignalTrackingPurchaseEvent(realCurrencyAmount: 123, realCurrencyType: "GBP", transactionID: "123-456-789")
            let signalTrackingSessionParameters = signalTrackingSessionEvent.dictionary()["eventParams"] as! [String : Any]
            XCTAssertEqual(networkType.rawValue, signalTrackingSessionParameters[PinpointerEventKey.connectionType.rawValue] as? String)
        }
    }
    
    private func fetchPath() -> NWPath {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue.global(qos: .background))
        let path = monitor.currentPath
        monitor.cancel()
        
        return path
    }
    
    func testCreateSignalTrackingSessionEvent_testBaseAndIdfaTrueParameters() throws {
        setTrackingHelperForIdfaTest(idfaIsPresent: true)

        let event: DDNAEvent = ddnaPinpointer.createSignalTrackingSessionEvent()
        let parameters = event.dictionary()["eventParams"] as! [String : Any]
        testIdfaOptions(idfaIsPresent: true, parameters: parameters)
        testBaseSignalMappingEvent(parameters: parameters)

        XCTAssertEqual(PinpointerEventName.session.rawValue, event.eventName)
    }

    func testCreateSignalTrackingSessionEvent_testBaseAndIdfaFalseParameters() throws {
        setTrackingHelperForIdfaTest(idfaIsPresent: false)

        let event: DDNAEvent = ddnaPinpointer.createSignalTrackingSessionEvent()
        let parameters = event.dictionary()["eventParams"] as! [String : Any]
        testIdfaOptions(idfaIsPresent: false, parameters: parameters)
        testBaseSignalMappingEvent(parameters: parameters)

        XCTAssertEqual(PinpointerEventName.session.rawValue, event.eventName)
    }

    func testCreateSignalTrackingInstallEvent_testBaseAndIdfaTrueParameters() throws {
        setTrackingHelperForIdfaTest(idfaIsPresent: true)
        
        let event: DDNAEvent = ddnaPinpointer.createSignalTrackingInstallEvent()
        let parameters = event.dictionary()["eventParams"] as! [String : Any]
        testIdfaOptions(idfaIsPresent: true, parameters: parameters)
        testBaseSignalMappingEvent(parameters: parameters)
        
        XCTAssertEqual(PinpointerEventName.install.rawValue, event.eventName)
    }
    
    func testCreateSignalTrackingInstallEvent_testBaseAndIdfaFalseParameters() throws {
        setTrackingHelperForIdfaTest(idfaIsPresent: false)
        
        let event: DDNAEvent = ddnaPinpointer.createSignalTrackingInstallEvent()
        let parameters = event.dictionary()["eventParams"] as! [String : Any]
        testIdfaOptions(idfaIsPresent: false, parameters: parameters)
        testBaseSignalMappingEvent(parameters: parameters)
        
        XCTAssertEqual(PinpointerEventName.install.rawValue, event.eventName)
    }
    
    func testCreateSignalTrackingPurchaseEvent_testBaseAndIdfaTrueParameters() throws {
        setTrackingHelperForIdfaTest(idfaIsPresent: true)

        let purchaseParameters: [String: Any] = [
            PinpointerEventKey.realCurrencyAmount.rawValue : 123 as NSNumber,
            PinpointerEventKey.realCurrencyType.rawValue : "GBP" as NSString,
            PinpointerEventKey.transactionID.rawValue : "123-456-789" as NSString
        ]

        let event: DDNAEvent = ddnaPinpointer.createSignalTrackingPurchaseEvent(realCurrencyAmount: purchaseParameters[PinpointerEventKey.realCurrencyAmount.rawValue] as! NSNumber, realCurrencyType: purchaseParameters[PinpointerEventKey.realCurrencyType.rawValue] as! NSString, transactionID: purchaseParameters[PinpointerEventKey.transactionID.rawValue] as! NSString)
        
        let parameters = event.dictionary()["eventParams"] as! [String : Any]
        testIdfaOptions(idfaIsPresent: true, parameters: parameters)
        testBaseSignalMappingEvent(parameters: parameters)

        XCTAssertEqual(PinpointerEventName.purchase.rawValue, event.eventName)
        
        XCTAssertEqual(purchaseParameters[PinpointerEventKey.realCurrencyAmount.rawValue] as? NSNumber, parameters[PinpointerEventKey.realCurrencyAmount.rawValue] as? NSNumber)
        XCTAssertEqual(purchaseParameters[PinpointerEventKey.realCurrencyType.rawValue] as? String, parameters[PinpointerEventKey.realCurrencyType.rawValue] as? String)
        XCTAssertEqual(purchaseParameters[PinpointerEventKey.transactionID.rawValue] as? String, parameters[PinpointerEventKey.transactionID.rawValue] as? String)
    }

    func testCreateSignalTrackingPurchaseEvent_testBaseAndIdfaFalseParameters() throws {
        setTrackingHelperForIdfaTest(idfaIsPresent: false)

        let purchaseParameters: [String: Any] = [
            PinpointerEventKey.realCurrencyAmount.rawValue : 123 as NSNumber,
            PinpointerEventKey.realCurrencyType.rawValue : "GBP" as NSString,
            PinpointerEventKey.transactionID.rawValue : "123-456-789" as NSString
        ]

        let event: DDNAEvent = ddnaPinpointer.createSignalTrackingPurchaseEvent(realCurrencyAmount: purchaseParameters[PinpointerEventKey.realCurrencyAmount.rawValue] as! NSNumber, realCurrencyType: purchaseParameters[PinpointerEventKey.realCurrencyType.rawValue] as! NSString, transactionID: purchaseParameters[PinpointerEventKey.transactionID.rawValue] as! NSString)
        
        let parameters = event.dictionary()["eventParams"] as! [String : Any]
        testIdfaOptions(idfaIsPresent: false, parameters: parameters)
        testBaseSignalMappingEvent(parameters: parameters)

        XCTAssertEqual(PinpointerEventName.purchase.rawValue, event.eventName)
        
        XCTAssertEqual(purchaseParameters[PinpointerEventKey.realCurrencyAmount.rawValue] as? NSNumber, parameters[PinpointerEventKey.realCurrencyAmount.rawValue] as? NSNumber)
        XCTAssertEqual(purchaseParameters[PinpointerEventKey.realCurrencyType.rawValue] as? String, parameters[PinpointerEventKey.realCurrencyType.rawValue] as? String)
        XCTAssertEqual(purchaseParameters[PinpointerEventKey.transactionID.rawValue] as? String, parameters[PinpointerEventKey.transactionID.rawValue] as? String)
    }

    private func setTrackingHelperForIdfaTest(idfaIsPresent: Bool = true) {
        if #available(iOS 14.0, *) {
            trackingHelperMock.status = idfaIsPresent ? .authorized : .denied
        }
        trackingHelperMock.idfaPresentReturns = idfaIsPresent
    }
    
    private func testBaseSignalMappingEvent(parameters: [String : Any]) {
        XCTAssertNotNil(parameters[PinpointerEventKey.deviceName.rawValue] as? String)
        XCTAssertNotNil(parameters[PinpointerEventKey.userCountry.rawValue] as? String)
        XCTAssertEqual(UIDevice.current.identifierForVendor?.uuidString as String?, parameters[PinpointerEventKey.idfv.rawValue] as? String)
       
        if #available(iOS 14.0, *) {
            XCTAssertEqual(trackingHelperMock.status.rawValue as NSNumber, parameters[PinpointerEventKey.attTrackingStatus.rawValue] as? NSNumber)
        } else {
            XCTAssertEqual(false, parameters[PinpointerEventKey.attTrackingStatus.rawValue] as? Bool)
        }
        
        XCTAssertEqual(mockDDNASDK.appStoreId, parameters[PinpointerEventKey.appStoreID.rawValue] as? String)
        XCTAssertEqual("com.apple.dt.xctest.tool", parameters[PinpointerEventKey.appBundleID.rawValue] as? String)
        XCTAssertEqual(false, parameters[PinpointerEventKey.privacyPermissionAds.rawValue] as? Bool)
        XCTAssertEqual(false, parameters[PinpointerEventKey.privacyPermissionExternal.rawValue] as? Bool)
        XCTAssertEqual(false, parameters[PinpointerEventKey.privacyPermissionGameExp.rawValue] as? Bool)
        XCTAssertEqual(false, parameters[PinpointerEventKey.privacyPermissionProfiling.rawValue] as? Bool)
        XCTAssertEqual("developer_consent", parameters[PinpointerEventKey.privacyPermissionMethod.rawValue] as? String)
        XCTAssertEqual(mockDDNASDK.appleDeveloperId, parameters[PinpointerEventKey.appDeveloperID.rawValue] as? String)
    }
    
    private func testIdfaOptions(idfaIsPresent: Bool = true, parameters: [String : Any]) {
        if idfaIsPresent {
            XCTAssertEqual(trackingHelperMock.trackingAuthorizationStatus as NSString, parameters[PinpointerEventKey.idfa.rawValue] as? NSString)
        } else {
            XCTAssertEqual(nil, parameters[PinpointerEventKey.idfa.rawValue] as? NSString)
        }
        
        XCTAssertEqual(!idfaIsPresent, parameters[PinpointerEventKey.limitedAdTracking.rawValue] as? Bool)
    }
}

