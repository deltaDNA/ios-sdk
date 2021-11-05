import XCTest
@testable import DeltaDNA

class DDNAEngageServiceTests: XCTestCase {
    
    var engageService: DDNAEngageService!
    var fakeFactory: DDNAInstanceFactoryMock!
    let request: DDNAEngageRequest = DDNAEngageRequest(decisionPoint: "testDecisionPoint", userId: "user-id-1234", sessionId: "session-id-12345")
    
    override func setUpWithError() throws {
        setEngageService(cacheExpiryInterval: 100)
        engageService.clearCache()
        
        self.fakeFactory = DDNAInstanceFactoryMock()
        fakeFactory.fakeNetworkRequest = DDNANetworkRequestMock()
        engageService.factory = fakeFactory
        
        DDNASDK.sharedInstance().consentTracker.piplExportStatus = .consentGiven
        DDNASDK.sharedInstance().consentTracker.piplUseStatus = .consentGiven
    }
    
    func test_responseFail_completionHandlerIsCalledAndReturnsCorrectArguments() throws {
        let message = "Request body couldn't be processed: One or more of the compulsory parameters are missing!"
        runBadFakeResponse(for: 400, data: message as NSString, expectedResult: message)
    }
    
    func test_responseSuccess_completionHandlerIsCalledAndReturnsCorrectArguments() throws {
        let requestDictionary: [String : Any] = [ "userID" : "user-id-1234",
                                        "sessionID" : "session-id-12345",
                                        "version" : "1.0.0",
                                        "sdkVersion" : "1.0.0","platform" : "iOS",
                                        "locale" : "en_UK",
                                        "timezoneOffset" : "-05",
                                        "manufacturer" : "Apple Inc.",
                                        "operatingSystemVersion" : "iOS 9.1",
                                        "decisionPoint" : "testDecisionPoint",
                                        "flavour" : "engagement",
                                        "parameters": ["foo" : "bar",
                                                       "score": 1]
                                      ]

        runGoodFakeRequest(with: requestDictionary.description)
    }
    
    func test_responseReturnsError_completionHandlerIsCalledAndReturnsCorrectArguments() throws {
        fakeFactory.fakeNetworkRequest = DDNANetworkRequestMock(with: "http://engage.net",
                                                                data: nil,
                                                                statusCode: -1,
                                                                error: NSError(domain: NSURLErrorDomain, code: -57, userInfo: nil))
           
        var resultResponse: String? = ""
        var resultStatusCode: Int = 0
        var resultError: NSError? = nil
           
        let request: DDNAEngageRequest = DDNAEngageRequest(decisionPoint: "testDecisionPoint", userId: "user-id-1234", sessionId: "session-id-12345")
        
        engageService.request(request, handler: { (response, statusCode, connectionError) in
            resultResponse = response
            resultStatusCode = statusCode
            resultError = connectionError as NSError?
        })
           
        XCTAssertNil(resultResponse)
        XCTAssertEqual(resultStatusCode, -1)
        XCTAssertEqual(resultError!.domain, NSURLErrorDomain)
        XCTAssertEqual(resultError!.code, -57)
        XCTAssertTrue(resultError!.userInfo.isEmpty)
    }
    
    func test_integration_cacheUsedCorrectly() throws {
        // Bad request with empty cache
        runBadFakeResponse(for: 400, data: "", expectedResult: "")
        
        // Good response, which should be added to cache
        runGoodFakeRequest(with: "{\"parameters\":{\"userID\":\"user-id-1234\"}}")

        // Bad request, returns value from cache
        runBadFakeResponse(for: 500, data: "", expectedResult: "{\"isCachedResponse\":true,\"parameters\":{\"userID\":\"user-id-1234\"}}")
        
        // Good response again
        runGoodFakeRequest(with: "{\"parameters\":{\"colour\":\"blue\"}}")
    }
    
    func test_integration_cacheDisabled() throws {
        setEngageService(cacheExpiryInterval: 0)
        engageService.clearCache()
        engageService.factory = fakeFactory
        
        // Bad request with empty cache
        runBadFakeResponse(for: 400, data: "", expectedResult: "")
        
        // Good response, which should be ignored cache
        runGoodFakeRequest(with: "{\"parameters\":{}}")
        
        // Bad request, passes respose straight back
        runBadFakeResponse(for: 400, data: "", expectedResult: "")
    
        // Good response again
        runGoodFakeRequest(with: "{\"parameters\":{\"colour\":\"blue\"}}")
    }
    
    private func setEngageService(cacheExpiryInterval: TimeInterval) {
        self.engageService = DDNAEngageService(environmentKey: "12345abcde",
                                               engageURL: "http://engage.net",
                                               hashSecret: nil,
                                               apiVersion: "1.0.0",
                                               sdkVersion: "1.0.0",
                                               platform: "iOS",
                                               locale: "en_UK",
                                               timezoneOffset: "-05",
                                               manufacturer: "Apple Inc.",
                                               operatingSystemVersion: "iOS 9.1",
                                               timeoutSeconds: 5,
                                               cacheExpiryInterval: cacheExpiryInterval)
    }
    
    private func runGoodFakeRequest(with data: String?) {
        fakeFactory.fakeNetworkRequest = DDNANetworkRequestMock(with: "http://engage.net",
                                                                data: data as NSString?,
                                                                statusCode: 200,
                                                                error: nil)
        
        var resultResponse: String? = ""
        var resultStatusCode: Int = 0
        var resultError: Error? = nil
        
        engageService.request(request, handler: { (response, statusCode, connectionError) in
            resultResponse = response
            resultStatusCode = statusCode
            resultError = connectionError as NSError?
        })
        
        XCTAssertEqual(resultResponse, data)
        XCTAssertEqual(resultStatusCode, 200)
        XCTAssertNil(resultError)
    }
    
    private func runBadFakeResponse(for statusCode: Int, data: NSString?, expectedResult: String?) {
        fakeFactory.fakeNetworkRequest = DDNANetworkRequestMock(with: "http://engage.net",
                                                                data: data as NSString?,
                                                                statusCode: statusCode,
                                                                error: nil)
        
        var resultResponse: String? = ""
        var resultStatusCode: Int = 0
        var resultError: NSError? = nil

        engageService.request(request, handler: { (response, statusCode, connectionError) in
            resultResponse = response
            resultStatusCode = statusCode
            resultError = connectionError as NSError?
        })
        
        XCTAssertEqual(resultResponse, expectedResult)
        XCTAssertEqual(resultStatusCode, statusCode)
        XCTAssertNil(resultError)
    }
}

