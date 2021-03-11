import XCTest
@testable import DeltaDNA

class DDNAUtilsTests: XCTestCase {
    
    func test_httpsNotIncludedInUrl_httpsIsAdded() throws {
        XCTAssertEqual(DDNAUtils.fixURL("collectURL"), "https://collectURL")
    }
    
    func test_httpIncludedInUrl_httpIsChangedToHttps() throws {
        XCTAssertEqual(DDNAUtils.fixURL("http://collectURL"), "https://collectURL")
    }
    
    func test_httpsIncludedInUrl_doNothing() throws {
        XCTAssertEqual(DDNAUtils.fixURL("https://URL"), "https://URL")
    }
}
