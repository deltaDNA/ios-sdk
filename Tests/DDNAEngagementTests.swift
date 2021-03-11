import XCTest
@testable import DeltaDNA

class DDNAEngagementTests: XCTestCase {

    var engagement: DDNAEngagement!
    
    override func setUpWithError() throws {
        engagement = DDNAEngagement(decisionPoint: "myDecisionPoint")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_createEngagementWithoutParameters() throws {
        let result: [String : Any] = [
            "decisionPoint" : "myDecisionPoint",
            "flavour" : "engagement",
            "parameters" : [:]
        ]
        
        XCTAssertEqual(engagement.dictionary() as NSDictionary, result as NSDictionary)
    }

    func test_createEngagementWithParameters() throws {
        engagement.setParam(5 as NSObject, forKey: "level")
        engagement.setParam("Kaboom!" as NSObject, forKey: "ending")
        
        let result: [String : Any] = [
            "decisionPoint" : "myDecisionPoint",
            "flavour" : "engagement",
            "parameters" : [
                "level" : 5,
                "ending" : "Kaboom!"
            ]
        ]
        
        XCTAssertEqual(engagement.dictionary() as NSDictionary, result as NSDictionary)
    }
    
    func test_createEngagementWithNestedParameters() throws {
        engagement.setParam(["level2": ["yo!": "greeting"]] as NSObject, forKey: "level1")
        
        let result: [String : Any] = [
            "decisionPoint" : "myDecisionPoint",
            "flavour" : "engagement",
            "parameters" : [
                "level1": [
                    "level2": [
                        "yo!": "greeting"
                    ]
                ]
            ]
        ]
        
        XCTAssertEqual(engagement.dictionary() as NSDictionary, result as NSDictionary)
    }
    
    func test_decisionPointIsNil_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNAEngagement(decisionPoint: nil)
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "decisionPoint cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_decisionPointIsEmptyString_throwInvalidArgumentException() throws {
        do {
            try ObjC.catchException {
                let _ = DDNAEngagement(decisionPoint: "")
            }
        }
        catch {
            let error = error as NSError
            XCTAssertNotNil(error)
            XCTAssertEqual(error.domain, NSExceptionName.invalidArgumentException.rawValue)
            XCTAssertEqual(error.localizedFailureReason, "decisionPoint cannot be nil or empty")
            return
        }
        XCTFail()
    }
    
    func test_jsonIsEmptyIfRawIsNotJson() throws {
        engagement.raw = "Not valid JSON"
        
        XCTAssertEqual(engagement.raw, "Not valid JSON")
        XCTAssertTrue(engagement.json.isEmpty)
    }
    
    func test_jsonIsValidIfRawIsJson() throws {
        engagement.raw = "{\"x\": 1,\"y\": \"Hello\",\"z\": [{\"1\": \"a\"}]}"
        
        XCTAssertEqual(engagement.raw, "{\"x\": 1,\"y\": \"Hello\",\"z\": [{\"1\": \"a\"}]}")
        XCTAssertNotNil(engagement.json)
        
        let result: [String : Any] = [
            "x": 1,
            "y": "Hello",
            "z": [
                [ "1": "a" ]
            ]
        ]
        
        XCTAssertEqual(engagement.json as NSDictionary, result as NSDictionary)
    }

}
