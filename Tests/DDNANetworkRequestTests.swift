import XCTest
@testable import DeltaDNA

class DDNANetworkRequestTests: XCTestCase {

    func test_networkRequest_callsDelegateWithValidResponse() throws {
        let url: URL = UrlMock(string: "http://deltadna.net")! as URL
        let payload: String = "{'greeting':'hello'}"
        
        let delegate: DDNANetworkRequestDelegateMock = DDNANetworkRequestDelegateMock()
        let request: DDNANetworkRequest = DDNANetworkRequest(url: url, jsonPayload: payload)
        request.delegate = delegate
        
        let resultStr: String = "{'foo': 'bar'}"
        let resultData: Data = resultStr.data(using: .utf8)!
        let resultResponse: HTTPURLResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        let mockSession = UrlSessionMock()
        mockSession.dataResponses.append((data: resultData, response: resultResponse, error: nil))
        
        request.urlSession = mockSession as NSURLSessionInterface

        request.send()
        
        XCTAssertEqual(request, delegate.receivedRequest)
        XCTAssertEqual(resultStr, delegate.didReceiveResponse)
        XCTAssertEqual(200, delegate.statusCode)
    }

    func test_callsDelegateWithInvalidRespons() throws {
        let url: URL = UrlMock(string: "http://deltadna.net")! as URL
        let payload: String = "{'greeting':'hello'}"
        
        let delegate: DDNANetworkRequestDelegateMock = DDNANetworkRequestDelegateMock()
        let request: DDNANetworkRequest = DDNANetworkRequest(url: url, jsonPayload: payload)
        request.delegate = delegate
        
        let resultStr: String = "{'foo': 'bar'}"
        let resultData: Data = resultStr.data(using: .utf8)!
        let resultResponse: HTTPURLResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: "HTTP/1.1", headerFields: nil)!
        let mockSession = UrlSessionMock()
        mockSession.dataResponses.append((data: resultData, response: resultResponse, error: nil))
        
        request.urlSession = mockSession as NSURLSessionInterface

        request.send()
        
        XCTAssertEqual(request, delegate.receivedRequest)
        XCTAssertEqual(resultStr, delegate.didFailWithResponse)
        XCTAssertEqual(404, delegate.statusCode)
    }
    
    func test_callsDelegateWithErrorResponse() throws {
        let url: URL = UrlMock(string: "http://deltadna.net")! as URL
        let payload: String = "{'greeting':'hello'}"
        
        let delegate: DDNANetworkRequestDelegateMock = DDNANetworkRequestDelegateMock()
        let request: DDNANetworkRequest = DDNANetworkRequest(url: url, jsonPayload: payload)
        request.delegate = delegate
        
        let resultError: NSError = NSError(domain: NSURLErrorDomain, code: -57, userInfo: nil)
        
        let mockSession = UrlSessionMock()
        mockSession.dataResponses.append((data: nil, response: nil, error: resultError))
        
        request.urlSession = mockSession as NSURLSessionInterface

        request.send()
        
        XCTAssertEqual(request, delegate.receivedRequest)
        XCTAssertNil(delegate.didFailWithResponse)
        XCTAssertEqual(-1, delegate.statusCode)
        XCTAssertEqual(delegate.error! as NSError, resultError)
    }
}
