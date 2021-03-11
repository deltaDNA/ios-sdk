import XCTest
@testable import DeltaDNA

class NSURL_DeltaDNATests: XCTestCase {
    
    func test_engageEndpointWithHttpAndKey_createSimpleHttpUrl() throws {
        let url: NSURL = NSURL(engageEndpoint: "http://engage1999abcd.deltadna.net", environmentKey: "5582251763508113932")
       
        let expectedUrl: NSURL? = NSURL(string: "http://engage1999abcd.deltadna.net/5582251763508113932")
    
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_engageEndpointWithHttpAndHash_createHashedHttpUrl() throws {
        let url: NSURL = NSURL(engageEndpoint:  "http://engage1999abcd.deltadna.net", environmentKey:  "5582251763508113932", payload: "{'foo': 'bar'}", hashSecret: "12345abcde")
        
        let expectedUrl: NSURL? = NSURL(string: "http://engage1999abcd.deltadna.net/5582251763508113932/hash/6172f13895b22d30359c6d6172a31d3a")
    
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_engageEndpointWithHttpsAndKey_createSimpleHttpsUrl() throws {
        let url: NSURL = NSURL(engageEndpoint: "https://engage1999abcd.deltadna.net", environmentKey: "5582251763508113932")
       
        let expectedUrl: NSURL? = NSURL(string: "https://engage1999abcd.deltadna.net/5582251763508113932")
        
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_engageEndpointWithHttpsAndHash_createHashedHttpsUrl() throws {
        let url: NSURL = NSURL(engageEndpoint:  "https://engage1999abcd.deltadna.net", environmentKey:  "5582251763508113932", payload: "{'foo': 'bar'}", hashSecret: "12345abcde")
        
        let expectedUrl: NSURL? = NSURL(string: "https://engage1999abcd.deltadna.net/5582251763508113932/hash/6172f13895b22d30359c6d6172a31d3a")
    
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_collectEndpointWithHttpAndKey_createsSimpleHttpUrl() throws {
        let url: NSURL = NSURL(collectEndpoint: "http://collect1999abcd.deltadna.net", environmentKey: "5582251763508113932")
       
        let expectedUrl: NSURL? = NSURL(string: "http://collect1999abcd.deltadna.net/5582251763508113932/bulk")
    
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_collectEndpointWithHttpAndHash_createHashedHttpUrl() throws {
        let url: NSURL = NSURL(collectEndpoint:  "http://collect1999abcd.deltadna.net", environmentKey:  "5582251763508113932", payload: "{'foo': 'bar'}", hashSecret: "12345abcde")
        
        let expectedUrl: NSURL? = NSURL(string: "http://collect1999abcd.deltadna.net/5582251763508113932/bulk/hash/6172f13895b22d30359c6d6172a31d3a")
    
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_collectEndpointWithHttpsAndKey_createsSimpleHttpsUrl() throws {
        let url: NSURL = NSURL(collectEndpoint: "https://collect1999abcd.deltadna.net", environmentKey: "5582251763508113932")
       
        let expectedUrl: NSURL? = NSURL(string: "https://collect1999abcd.deltadna.net/5582251763508113932/bulk")
        
        XCTAssertEqual(url, expectedUrl)
    }
    
    func test_collectEndpointWithHttpsAndHash_createHashedHttpsUrl() throws {
        let url: NSURL = NSURL(collectEndpoint:  "https://collect1999abcd.deltadna.net", environmentKey:  "5582251763508113932", payload: "{'foo': 'bar'}", hashSecret: "12345abcde")
        
        let expectedUrl: NSURL? = NSURL(string: "https://collect1999abcd.deltadna.net/5582251763508113932/bulk/hash/6172f13895b22d30359c6d6172a31d3a")
    
        XCTAssertEqual(url, expectedUrl)
    }
}
