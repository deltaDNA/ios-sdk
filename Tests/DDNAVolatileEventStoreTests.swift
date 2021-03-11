import XCTest

class DDNAVolatileEventStoreTests: XCTestCase {
    var store: DDNAVolatileEventStore!
    
    override func setUpWithError() throws {
        store = DDNAVolatileEventStore(sizeBytes: 64)
    }
    
    func testCreateEnEventStoreOfRequestedSize() throws {
        XCTAssertNotNil(store)
        XCTAssertTrue(store.isOutEmpty())
    }
    
    func testAcceptEventsUpToTheMaximumSize() throws {
        let event: [String: Any] = ["name" : "Jan", "age" : 6]
        XCTAssertTrue(store.pushEvent(event))
        XCTAssertTrue(store.pushEvent(event))
        XCTAssertFalse(store.pushEvent(event))
        
        XCTAssertNotNil(store)
        XCTAssertTrue(store.isOutEmpty())
    }
    
    func testHandlesEmptyEvents() throws {
        let event: [String : Any] = [:]
        
        XCTAssertFalse(store.pushEvent(event))
    }
    
    func testHandlesCorruptEvents() throws {
        var event: [String : Any] = [:]
        
        let danger: NSObject = NSObject()
        event["danger"] = danger

        XCTAssertFalse(store.pushEvent(event))
    }

    func testReadsEvents() throws {
        let event1: [String : Any] = ["name" : "Jan",
                                      "age" : 6]
        
        let event2: [String : Any] = ["name" : "Ben",
                                      "age" : 14]
        
        let event3: [String : Any] = ["name" : "Jen",
                                      "age" : 10]
        
        let event4: [String : Any] = ["name" : "Lou",
                                      "age" : 8]
        
        let event5: [String : Any] = ["name" : "Sam",
                                      "age" : 12]
        
        XCTAssertTrue(store.pushEvent(event1))
        XCTAssertTrue(store.pushEvent(event2))
        XCTAssertFalse(store.pushEvent(event3))
        XCTAssertTrue(store.isOutEmpty())
        XCTAssertTrue(store.swapBuffers())
        XCTAssertFalse(store.isOutEmpty())
        XCTAssertTrue(store.pushEvent(event3))
        XCTAssertTrue(store.pushEvent(event4))
        XCTAssertFalse(store.pushEvent(event5))
        
        var events = store.readOut()
        
        XCTAssertNotNil(events)
        XCTAssertEqual(events?.count, 2)
        
        if let events = events {
            let event1Data = (events[0] as! String).data(using: String.Encoding.utf8)
            let event1 = try? JSONSerialization.jsonObject(with: event1Data!, options: []) as? [String : Any]
            XCTAssertEqual(event1!["name"] as! String, "Jan")
            XCTAssertEqual(event1!["age"] as! Int, 6)
            
            let event2Data = (events[1] as! String).data(using: String.Encoding.utf8)
            let event2 = try? JSONSerialization.jsonObject(with: event2Data!, options: []) as? [String : Any]
            XCTAssertEqual(event2!["name"] as! String, "Ben")
            XCTAssertEqual(event2!["age"] as! Int, 14)
        }
        XCTAssertFalse(store.swapBuffers())
        
        store.clearOut()
        XCTAssertTrue(store.isOutEmpty())
        XCTAssertTrue(store.swapBuffers())
        XCTAssertFalse(store.isOutEmpty())
        XCTAssertTrue(store.pushEvent(event5))
       
        events = store.readOut()
        XCTAssertNotNil(events)
        XCTAssertEqual(events?.count, 2)
       
        if let events = events {
            let event1Data = (events[0] as! String).data(using: String.Encoding.utf8)
            let event1 = try? JSONSerialization.jsonObject(with: event1Data!, options: []) as? [String : Any]
            XCTAssertEqual(event1!["name"] as! String, "Jen")
            XCTAssertEqual(event1!["age"] as! Int, 10)
            
            let event2Data = (events[1] as! String).data(using: String.Encoding.utf8)
            let event2 = try? JSONSerialization.jsonObject(with: event2Data!, options: []) as? [String : Any]
            XCTAssertEqual(event2!["name"] as! String, "Lou")
            XCTAssertEqual(event2!["age"] as! Int, 8)
        }
        XCTAssertFalse(store.swapBuffers())
       
        store.clearOut()
        XCTAssertTrue(store.isOutEmpty())
        XCTAssertTrue(store.swapBuffers())
        XCTAssertFalse(store.isOutEmpty())

        events = store.readOut()
        XCTAssertNotNil(events)
        XCTAssertEqual(events?.count, 1)
        if let events = events {
            let event1Data = (events[0] as! String).data(using: String.Encoding.utf8)
            let event1 = try? JSONSerialization.jsonObject(with: event1Data!, options: []) as? [String : Any]
            XCTAssertEqual(event1!["name"] as! String, "Sam")
            XCTAssertEqual(event1!["age"] as! Int, 12)
        }
        store.clearOut()
        XCTAssertTrue(store.isOutEmpty())
        XCTAssertTrue(store.swapBuffers())
        XCTAssertTrue(store.isOutEmpty())
    }
    
    func testClearEventStore() throws {
        let event: [String : Any] = ["name" : "Jan",
                                      "age" : 6]
        
        XCTAssertTrue(store.isInEmpty())
        XCTAssertTrue(store.isOutEmpty())
        XCTAssertTrue(store.pushEvent(event))
        XCTAssertFalse(store.isInEmpty())
        XCTAssertTrue(store.isOutEmpty())
        XCTAssertTrue(store.swapBuffers())
        XCTAssertTrue(store.isInEmpty())
        XCTAssertFalse(store.isOutEmpty())
        XCTAssertTrue(store.pushEvent(event))
        XCTAssertFalse(store.isInEmpty())
        XCTAssertFalse(store.isOutEmpty())
        store.clearAll()
        XCTAssertTrue(store.isInEmpty())
        XCTAssertTrue(store.isOutEmpty())
    }

}
