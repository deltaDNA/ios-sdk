import XCTest
@testable import DeltaDNA

class DDNAGameParametersHandlerTests: XCTestCase {
    var store: DDNAActionStoreMock!
    
    override func setUpWithError() throws {
        store = DDNAActionStoreMock()
    }

    func test_handlesGameParameters() throws {
        var called: Bool = false
        var returnedParameters: [AnyHashable : Any]? = nil
        
        let mockTrigger: DDNAEventTriggerMock = DDNAEventTriggerMock()
        mockTrigger.willReturnActionType = "imageMessage"
        
        let handler: DDNAGameParametersHandler = DDNAGameParametersHandler(handler: { parameters in
            called = true
            returnedParameters = parameters
        })
        
        XCTAssertEqual(handler.type(), "gameParameters")
        
        handler.handle(mockTrigger, store: store)
        XCTAssertFalse(called)
        
        mockTrigger.willReturnActionType = "gameParameters"
        mockTrigger.willReturnResponse = ["parameters" : [ "a" : 1 ]]
        
        handler.handle(mockTrigger, store: store)
        XCTAssertTrue(called)
        XCTAssertEqual(returnedParameters as NSDictionary?, ["a" : 1 ] as NSDictionary)
        XCTAssertFalse(store.removeWasCalled)
    }

    func test_handlesPersistentGameParametersActionAndRemovesIt() throws {
        var called: Bool = false
        var returnedParameters: [AnyHashable : Any]? = nil
        
        let handler: DDNAGameParametersHandler = DDNAGameParametersHandler(handler: { parameters in
            called = true
            returnedParameters = parameters
        })
        
        let mockTrigger: DDNAEventTriggerMock = DDNAEventTriggerMock()
        mockTrigger.willReturnActionType = "gameParameters"
        mockTrigger.willReturnResponse = ["parameters" : ["a" : 1]]
        store.willReturnParametersForTrigger = ["b" : 2]
        
        handler.handle(mockTrigger, store: store)
        XCTAssertTrue(called)
        XCTAssertEqual(returnedParameters as NSDictionary?, ["b" : 2] as NSDictionary)
        XCTAssertTrue(store.removeWasCalled)
    }
    
    func test_handlesEmptyResponse() throws {
        var called: Bool = false
        var returnedParameters: [AnyHashable : Any]? = nil
        
        let handler: DDNAGameParametersHandler = DDNAGameParametersHandler(handler: { parameters in
            called = true
            returnedParameters = parameters
        })
        
        let mockTrigger: DDNAEventTriggerMock = DDNAEventTriggerMock()
        mockTrigger.willReturnActionType = "gameParameters"
        mockTrigger.willReturnResponse = [:]
        
        handler.handle(mockTrigger, store: store)
        XCTAssertTrue(called)
        XCTAssertTrue(returnedParameters!.isEmpty)
        XCTAssertFalse(store.removeWasCalled)
    }
}
