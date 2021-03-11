import XCTest

class DDNAEventTests: XCTestCase {

    var event: DDNAEvent!
    
    override func setUpWithError() throws {
        event = DDNAEvent(name: "myEvent")
    }

    override func tearDownWithError() throws {
    }

    func testCreateWithourParameters() throws {
        let result: [String: Any] = [ "eventName" : "myEvent",
                                      "eventParams" : [:] ]
        
        XCTAssertEqual(event.eventName, "myEvent")
        XCTAssertEqual(event.dictionary() as NSDictionary, result as NSDictionary)
    }
    
    func testCreateWithParameters() throws {
        event.setParam(5 as NSObject, forKey: "level")
        event.setParam("Kaboom!" as NSObject, forKey: "ending")
        
        let result: [String: Any] = [ "eventName": "myEvent",
                                      "eventParams": [ "level": 5,
                                                       "ending": "Kaboom!" ] ]
        
        XCTAssertEqual(event.dictionary() as NSDictionary, result as NSDictionary)
    }
    
    func testCreateWithNestedParameters() throws {
        event.setParam(["level2" : [ "yo!" : "greeting"]] as NSObject, forKey: "level1")
        
        let result: [String: Any] = [ "eventName": "myEvent",
                                      "eventParams": [ "level1": [ "level2" : [ "yo!" : "greeting"]]]]
        
        XCTAssertEqual(event.dictionary() as NSDictionary, result as NSDictionary)
        
    }
    
    func testNotThrowingIfSetParamIsNil() throws {
       XCTAssertNoThrow(event.setParam(nil, forKey: "nilKey"))
    }
    
    func testRemovePreviouslyAddedParamIfSetToNil() throws {
        event.setParam("someValue" as NSObject, forKey: "testKey")
        event.setParam(nil, forKey: "testKey")
        let eventParams: [String:String] = event.dictionary()["eventParams"] as! [String:String]
        XCTAssertFalse(eventParams.keys.contains("testKey"))
    }
    
    func testCanCopyAnEvent() throws {
        event.setParam(["level2" : [ "yo!" : "greeting"]] as NSObject, forKey: "level1")
        let eventCopy: DDNAEvent = event.copy() as! DDNAEvent
        
        XCTAssertNotNil(eventCopy)
        XCTAssertNotEqual(eventCopy, event)
        XCTAssertEqual(eventCopy.dictionary() as NSDictionary, event.dictionary() as NSDictionary)
    }
}
