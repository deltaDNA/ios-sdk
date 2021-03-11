import XCTest
@testable import DeltaDNA

class DDNAImageMessageHandlerTests: XCTestCase {
    
    var store: DDNAActionStoreMock!
    
    override func setUpWithError() throws {
        store = DDNAActionStoreMock()
        swizzleFunctions(swizzleClass: DDNAImageMessage.self, originalMethod: #selector(DDNAImageMessage.fetchResources), mockedMethod: #selector(DDNAImageMessage.fetchResourcesMock))
    }
    
    override func tearDownWithError() throws {
        swizzleFunctions(swizzleClass: DDNAImageMessage.self, originalMethod: #selector(DDNAImageMessage.fetchResourcesMock), mockedMethod: #selector(DDNAImageMessage.fetchResources))
    }
    
    func test_handlesImageMessages() throws {
        var called: Bool = false
        var returnedImageMessage: DDNAImageMessage? = nil
        
        swizzleFunctions(swizzleClass: object_getClass(DDNAImageCache.self), originalMethod: #selector(DDNAImageCache.sharedInstance), mockedMethod: #selector(DDNAImageCache.sharedInstanceMockWithImage))
        
        let mockTrigger: DDNAEventTriggerMock = DDNAEventTriggerMock()
        mockTrigger.willReturnActionType = "gameParameters"
        
        let handler: DDNAImageMessageHandler = DDNAImageMessageHandler(handler: { imageMessage in
            called = true
            returnedImageMessage = imageMessage
        })
        
        XCTAssertEqual(handler.type(), "imageMessage")
        
        handler.handle(mockTrigger, store: store)
        XCTAssertFalse(called)
        
        mockTrigger.willReturnActionType = "imageMessage"
        mockTrigger.willReturnResponse = ["parameters" :  ["a": 1],
                                                           "image": [
                                                            "url" : "/image",
                                                            "height" : 1,
                                                            "width" : 1,
                                                            "spritemap": [
                                                                "background": [:]
                                                            ],
                                                            "layout" : [
                                                                "landscape" : [:]
                                                            ]
                                                           ]]
        
        handler.handle(mockTrigger, store: store)
        XCTAssertTrue(called)
        XCTAssertNotNil(returnedImageMessage)
        XCTAssertEqual(returnedImageMessage?.parameters as NSDictionary?, ["a" : 1] as NSDictionary)
        XCTAssertFalse(store.removeWasCalled)
        
        swizzleFunctions(swizzleClass: object_getClass(DDNAImageCache.self), originalMethod: #selector(DDNAImageCache.sharedInstanceMockWithImage), mockedMethod: #selector(DDNAImageCache.sharedInstance))
    }
    
    func test_persistedImageActionIsPresent_handlesActionAndRemovesIt() throws {
        var called: Bool = false
        var returnedImageMessage: DDNAImageMessage? = nil
        
        swizzleFunctions(swizzleClass: object_getClass(DDNAImageCache.self), originalMethod: #selector(DDNAImageCache.sharedInstance), mockedMethod: #selector(DDNAImageCache.sharedInstanceMockWithImage))
        
        let mockTrigger: DDNAEventTriggerMock = DDNAEventTriggerMock()
        mockTrigger.willReturnActionType = "imageMessage"
        mockTrigger.willReturnResponse = ["parameters" :  ["a": 1],
                                                           "image": [
                                                            "url" : "/image",
                                                            "height" : 1,
                                                            "width" : 1,
                                                            "spritemap": [
                                                                "background": [:]
                                                            ],
                                                            "layout" : [
                                                                "landscape" : [:]
                                                            ]
                                                           ]]
        store.willReturnParametersForTrigger = ["b" : 2]
        
        let handler: DDNAImageMessageHandler = DDNAImageMessageHandler(handler: { imageMessage in
            called = true
            returnedImageMessage = imageMessage
        })
        XCTAssertEqual(handler.type(), "imageMessage")
        
        handler.handle(mockTrigger, store: store)
        XCTAssertTrue(called)
        XCTAssertEqual(returnedImageMessage?.parameters as NSDictionary?, ["b" : 2] as NSDictionary)
        XCTAssertTrue(store.removeWasCalled)
        
        swizzleFunctions(swizzleClass: object_getClass(DDNAImageCache.self), originalMethod: #selector(DDNAImageCache.sharedInstanceMockWithImage), mockedMethod: #selector(DDNAImageCache.sharedInstance))
    }
    
    func test_resourcesAreMissing_doesNotReturnImageMessage() throws {
        var called: Bool = false
        var returnedImageMessage: DDNAImageMessage? = nil
        
        swizzleFunctions(swizzleClass: object_getClass(DDNAImageCache.self), originalMethod: #selector(DDNAImageCache.sharedInstance), mockedMethod: #selector(DDNAImageCache.sharedInstanceMockNoImage))
        
        let mockTrigger: DDNAEventTriggerMock = DDNAEventTriggerMock()
        mockTrigger.willReturnActionType = "imageMessage"
        mockTrigger.willReturnResponse = ["parameters" :  ["a": 1],
                                                           "image": [
                                                            "url" : "/image",
                                                            "height" : 1,
                                                            "width" : 1,
                                                            "spritemap": [
                                                                "background": [:]
                                                            ],
                                                            "layout" : [
                                                                "landscape" : [:]
                                                            ]
                                                           ]]
        let handler: DDNAImageMessageHandler = DDNAImageMessageHandler(handler: { imageMessage in
            called = true
            returnedImageMessage = imageMessage
        })
        XCTAssertEqual(handler.type(), "imageMessage")
        
        handler.handle(mockTrigger, store: store)
        XCTAssertFalse(called)
        XCTAssertNil(returnedImageMessage)
        XCTAssertFalse(store.removeWasCalled)
        
        swizzleFunctions(swizzleClass: object_getClass(DDNAImageCache.self), originalMethod: #selector(DDNAImageCache.sharedInstanceMockNoImage), mockedMethod: #selector(DDNAImageCache.sharedInstance))
    }
    
    private func swizzleFunctions(swizzleClass: AnyClass?, originalMethod: Selector, mockedMethod: Selector) {
        let originalMethod = class_getInstanceMethod(swizzleClass, originalMethod)
        let mockedMethod = class_getInstanceMethod(swizzleClass, mockedMethod)
        if let originalMethod = originalMethod, let mockedMethod = mockedMethod {
            method_exchangeImplementations(originalMethod, mockedMethod)
        }
    }
}
