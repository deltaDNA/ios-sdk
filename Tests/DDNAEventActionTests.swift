import XCTest
@testable import DeltaDNA

class DDNAEventActionTests: XCTestCase {
    var event: DDNAEvent!
    var actionStore: DDNAActionStore!
    var uut: DDNAEventAction!
    
    override func setUpWithError() throws {
        event = DDNAEvent(name: "test")
        actionStore = DDNAActionStoreMock(path: "test")
        uut = DDNAEventAction()
    }

    func test_runEmptyEvent_noErrorsReturned() throws {
        do {
            try ObjC.catchException {
                self.uut.run()
            }
        }
        catch {
            XCTFail()
        }
        
        XCTAssertTrue(true)
    }
    
    func test_runThreeTriggersWithPriorities_triggersRunInOrder() throws {
        let trigger1 = DDNAEventTrigger(dictionary: ["priority" : 5])
        let trigger2 = DDNAEventTrigger(dictionary: ["priority" : 3])
        let trigger3 = DDNAEventTrigger(dictionary: ["priority" : 1])
        let triggers: NSOrderedSet = NSOrderedSet(orderedSet: [trigger1!, trigger2!, trigger3!])
        
        let mockSettings: DDNASettings = DDNASettings()
        let mockSdk: DDNASdkInterfaceMock = DDNASdkInterfaceMock()
        
        uut = DDNAEventAction(eventSchema: event.dictionary(), eventTriggers: triggers, sdk: mockSdk, store: actionStore, settings: mockSettings)
        uut.run()
        XCTAssertEqual(mockSdk.recordedEvents.count, 3)
        
        let firstRecordedEventParams = mockSdk.recordedEvents[0].dictionary()["eventParams"] as! [String : Any]
        let secondRecordedEventParams = mockSdk.recordedEvents[1].dictionary()["eventParams"] as! [String : Any]
        let thirdRecordedEventParams = mockSdk.recordedEvents[2].dictionary()["eventParams"] as! [String : Any]
        
        XCTAssertEqual(firstRecordedEventParams["ddnaEventTriggeredCampaignPriority"] as! Int, 5)
        XCTAssertEqual(secondRecordedEventParams["ddnaEventTriggeredCampaignPriority"] as! Int, 3)
        XCTAssertEqual(thirdRecordedEventParams["ddnaEventTriggeredCampaignPriority"] as! Int, 1)
    }
    
    func test_handlesAreRun_finishWhenOneHandlesTheAction() throws {
        let trigger = DDNAEventTriggerMock()
        let triggers: NSOrderedSet = NSOrderedSet(orderedSet: [trigger])
        let mockSettings: DDNASettings = DDNASettings()
        let mockSdk: DDNASdkInterfaceMock = DDNASdkInterfaceMock()
        
        let h1: DDNAEventActionHandlerMock = DDNAEventActionHandlerMock()
        let h2: DDNAEventActionHandlerMock = DDNAEventActionHandlerMock()
        let h3: DDNAEventActionHandlerMock = DDNAEventActionHandlerMock()
        
        trigger.expectedResponseToResponds = true
        h1.expectedHandleReturn = false
        h2.expectedHandleReturn = true
        
        uut = DDNAEventAction(eventSchema: event.dictionary(), eventTriggers: triggers, sdk: mockSdk, store: actionStore, settings: mockSettings)
        uut.add(h1)
        uut.add(h2)
        uut.add(h3)
        uut.run()
        
        XCTAssertEqual(h1.handleTriggerCountForValues.count, 1)
        XCTAssertEqual(h2.handleTriggerCountForValues.count, 1)
        XCTAssertEqual(h3.handleTriggerCountForValues.count, 0)
        
        XCTAssertTrue(h1.handleTriggerCountForValues[0]["eventTrigger"]! as! NSObject == trigger)
        XCTAssertEqual(h1.handleTriggerCountForValues[0]["store"] as? DDNAActionStore, actionStore)
        
        XCTAssertTrue(h2.handleTriggerCountForValues[0]["eventTrigger"]! as! NSObject == trigger)
        XCTAssertEqual(h2.handleTriggerCountForValues[0]["store"] as? DDNAActionStore, actionStore)
    }
    
    func test_emptyAction_doNothing() throws {
        let trigger = DDNAEventTriggerMock()
        let h1: DDNAEventActionHandlerMock = DDNAEventActionHandlerMock()
        trigger.expectedResponseToResponds = true
        h1.expectedHandleReturn = true
        uut.add(h1)
        uut.run()
        
        XCTAssertEqual(h1.handleTriggerCountForValues.count, 0)
    }
    
    func test_postAction_triggerEvent() throws {
        let trigger = DDNAEventTriggerMock(dictionary: [
            "campaignID" : 1,
            "priority" : 2,
            "variantID" : 3,
            "response" : [ "eventParams" :
                            ["responseEngagementName" : "campaignName",
                             "responseVariantName" : "variantName"] ],
            "actionType" : "gameParameters",
            "count" : 1])
        
        let triggers: NSOrderedSet = NSOrderedSet(orderedSet: [trigger!])
        let mockSettings: DDNASettings = DDNASettings()
        let mockSdk: DDNASdkInterfaceMock = DDNASdkInterfaceMock()
        mockSettings.multipleActionsForEventTriggerEnabled = false
        
        trigger!.expectedResponseToResponds = true
        uut = DDNAEventAction(eventSchema: event.dictionary(), eventTriggers: triggers, sdk: mockSdk, store: actionStore, settings: mockSettings)
        uut.run()
        
        XCTAssertEqual(mockSdk.recordedEvents.count, 1)
        let recordedEvent = mockSdk.recordedEvents[0].dictionary() as! [String : Any]
        XCTAssertEqual(recordedEvent["eventName"] as! String, "ddnaEventTriggeredAction")
        let recordedEventParams = recordedEvent["eventParams"] as! [String : Any]
        XCTAssertEqual(recordedEvent["eventName"] as! String, "ddnaEventTriggeredAction")
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredCampaignID"] as! Int, 1)
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredCampaignPriority"] as! Int, 2)
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredVariantID"] as! Int, 3)
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredCampaignName"] as! String, "campaignName")
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredVariantName"] as! String, "variantName")
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredActionType"] as! String, "gameParameters")
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredSessionCount"] as! Int, 1)
    }
    
    func test_eventMissingOptionalFields_postActionFinishedWithoutErrors() throws {
        let trigger = DDNAEventTriggerMock(dictionary: [
            "campaignID" : 1,
            "priority" : 2,
            "variantID" : 3,
            "actionType" : "gameParameters",
            "count" : 1])
        
        let triggers: NSOrderedSet = NSOrderedSet(orderedSet: [trigger!])
        let mockSettings: DDNASettings = DDNASettings()
        let mockSdk: DDNASdkInterfaceMock = DDNASdkInterfaceMock()
        trigger!.expectedResponseToResponds = true
        
        uut = DDNAEventAction(eventSchema: event.dictionary(), eventTriggers: triggers, sdk: mockSdk, store: actionStore, settings: mockSettings)
        uut.run()
        
        XCTAssertEqual(mockSdk.recordedEvents.count, 1)
        let recordedEvent = mockSdk.recordedEvents[0].dictionary() as! [String : Any]
        let recordedEventParams = recordedEvent["eventParams"] as! [String : Any]
        
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredCampaignID"] as! Int, 1)
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredCampaignPriority"] as! Int, 2)
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredVariantID"] as! Int, 3)
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredActionType"] as! String, "gameParameters")
        XCTAssertEqual(recordedEventParams["ddnaEventTriggeredSessionCount"] as! Int, 1)
        
        XCTAssertNil(recordedEventParams["ddnaEventTriggeredCampaignName"])
        XCTAssertNil(recordedEventParams["ddnaEventTriggeredVariantName"])
    }
}

