import Foundation
import XCTest
@testable import DeltaDNA

class URLSessionDataTaskMock: URLSessionDataTask {
    override func resume() {
        // Do nothing
    }
}

class URLSessionWithDataTaskMock: URLSessionDataTaskProtocol {
    var dataToReturn: Data?
    var error: Error?
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(dataToReturn, nil, error)
        return URLSessionDataTaskMock() // Deprecated, but doesn't really matter as we don't use this return value
    }
}

class GeoIpNetworkClientTests: XCTestCase {
    var geoIpClient: GeoIpNetworkClient!
    var urlSessionMock: URLSessionWithDataTaskMock!
    
    override func setUp() {
        urlSessionMock = URLSessionWithDataTaskMock()
        geoIpClient = GeoIpNetworkClient(urlSession: urlSessionMock)
    }
    
    func test_ifErrorIsReturned_correctCallbackParamsAreReturned() {
        let expectationToCheck = expectation(description: "Ensure callback is called")
        
        urlSessionMock.error = URLError(.notConnectedToInternet)
        
        geoIpClient.fetchGeoIpResponse {(response, error) in
            XCTAssertNil(response)
            XCTAssertEqual((error as? URLError)?.code, URLError.Code.notConnectedToInternet)
            expectationToCheck.fulfill()
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }
    
    func test_ifResponseIsReturned_correctCallbackParamsAreReturned() {
        let expectationToCheck = expectation(description: "Ensure callback is called")
        
        let responseObject = GeoIpResponse(identifier: "pipl", country: "cn", region: "beijing", ageGateLimit: 13)
        urlSessionMock.dataToReturn = try! JSONEncoder().encode(responseObject)
        
        geoIpClient.fetchGeoIpResponse {(response, error) in
            XCTAssertEqual(responseObject.identifier, response?.identifier)
            XCTAssertNil(error)
            expectationToCheck.fulfill()
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }
    
    func test_ifInvalidResponseIsReturned_correctCallbackParamsAreReturned() {
        let expectationToCheck = expectation(description: "Ensure callback is called")
        
        let responseObject = ["notAValidObject": 1234]
        urlSessionMock.dataToReturn = try! JSONEncoder().encode(responseObject)
        
        geoIpClient.fetchGeoIpResponse {(response, error) in
            XCTAssertNil(response)
            XCTAssertNotNil(error)
            expectationToCheck.fulfill()
        }
        
        waitForExpectations(timeout: 3) { error in
            if let error = error {
                XCTFail("\(error)")
            }
        }
    }
}
