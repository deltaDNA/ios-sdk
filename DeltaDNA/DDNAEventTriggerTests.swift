import XCTest
@testable import DeltaDNA

class DDNAEventTriggerTests: XCTestCase {
    override func setUpWithError() throws {
        // This isn't ideal, but is needed to reset the shared metric store between tests
        // so we can do an integration test for the trigger conditions.
        // It runs in the setup phase because we might have already polluted this file from other tests that
        // don't mock the metric store.
        let sharedMetricStorePath = URL(fileURLWithPath: DDNASettings.getPrivateSettingsDirectoryPath()).appendingPathComponent("ddnaETCCountStore")
        if FileManager.default.fileExists(atPath: sharedMetricStorePath.path) {
            try FileManager.default.removeItem(at: sharedMetricStorePath)
        }
        DDNAEventTriggeredCampaignMetricStore.sharedInstance.readCountFromFile()
    }

    func test_eventTrigger_buildsItselfFromAJsonDictionary() throws {
        let response = [
            "parameters": [ "a": 1 ],
            "eventParams": [
                "responseEngagementName": "campaignName",
                "responseVariantName": "variantName"
            ]
        ]
        
        let dictionary: [String : Any] = [
            "eventName": "testEvent",
            "response": response,
            "campaignID": 1,
            "variantID": 2,
            "priority": 3,
            "limit": 4
        ]
        
        let eventTrigger: DDNAEventTrigger = DDNAEventTrigger(dictionary: dictionary)
        
        XCTAssertEqual(eventTrigger.eventName, "testEvent")
        XCTAssertEqual(eventTrigger.actionType, "gameParameters")
        XCTAssertEqual(eventTrigger.response as NSDictionary, response as NSDictionary)
        XCTAssertEqual(eventTrigger.campaignId, 1)
        XCTAssertEqual(eventTrigger.variantId, 2)
        XCTAssertEqual(eventTrigger.campaignName, "campaignName")
        XCTAssertEqual(eventTrigger.variantName, "variantName")
        XCTAssertEqual(eventTrigger.priority, 3)
        XCTAssertEqual(eventTrigger.limit, 4)
    }

    func test_eventTrigger_usesSensibleDefaults() throws {
        let eventTrigger: DDNAEventTrigger = DDNAEventTrigger(dictionary: [:])
        
        XCTAssertNil(eventTrigger.eventName)
        XCTAssertEqual(eventTrigger.actionType, "gameParameters")
        XCTAssertTrue(eventTrigger.response.isEmpty)
        XCTAssertEqual(eventTrigger.campaignId, 0)
        XCTAssertEqual(eventTrigger.variantId, 0)
        XCTAssertNil(eventTrigger.campaignName)
        XCTAssertNil(eventTrigger.variantName)
        XCTAssertEqual(eventTrigger.priority, 0)
        XCTAssertNil(eventTrigger.limit)
    }
    
    func test_eventTrigger_ordersTriggersByPriority() throws {
        let eventTrigger1: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["priority" : 1])
        let eventTrigger2: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["priority" : 2])
        let eventTrigger3: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["priority" : 3])

        let array = [eventTrigger1, eventTrigger2, eventTrigger3]
        let sortedArray = array.sorted{$0.priority > $1.priority}
        
        XCTAssertEqual(sortedArray, [eventTrigger3, eventTrigger2, eventTrigger1])
    }
    
    func test_eventTrigger_failsIfEventNameDoesNotMatch() throws {
        let eventTrigger: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["eventName" : "testEvent"])
        XCTAssertFalse(eventTrigger.responds(toEventSchema: ["eventName" : "anotherEvent"]))
    }
    
    func test_eventTrigger_respectsTriggerLimit() throws {
        let eventTrigger: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["limit" : 2])
        XCTAssertTrue(eventTrigger.responds(toEventSchema: [:]))
        XCTAssertTrue(eventTrigger.responds(toEventSchema: [:]))
        XCTAssertFalse(eventTrigger.responds(toEventSchema: [:]))
    }
    
    func test_eventTrigger_handlesTriggersWithEmptyConditions() throws {
        let eventTrigger: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["eventName" : "testEvent"])
        XCTAssertFalse(eventTrigger.responds(toEventSchema: ["eventName" : "anotherEvent"]))
    }
    
    func test_evaluatesLogicalOperators() throws {
        XCTAssertTrue(cond(parameters: [:], condition: [["b":true], ["b":true], ["o":"and"]]))
        XCTAssertFalse(cond(parameters: [:], condition: [["b":true], ["b":false], ["o":"and"]]))
        
        XCTAssertTrue(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"and"]]))
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":false], ["o":"and"]]))
        
        XCTAssertTrue(cond(parameters: [:], condition: [["b":false], ["b":true], ["o":"or"]]))
        XCTAssertFalse(cond(parameters: [:], condition: [["b":false], ["b":false], ["o":"or"]]))
        
        XCTAssertTrue(cond(parameters: ["a":false], condition: [["p":"a"], ["b":true], ["o":"or"]]))
        XCTAssertFalse(cond(parameters: ["a":false], condition: [["p":"a"], ["b":false], ["o":"or"]]))
    }
    
    func test_evaluatesOperatorsAgainstIncompatibleTypes() throws {
        XCTAssertFalse(cond(parameters: ["a":1], condition: [["p":"a"], ["i":1], ["o":"and"]]))
        XCTAssertFalse(cond(parameters: ["a":1.0], condition: [["p":"a"], ["f":1.0], ["o":"and"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"and"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"and"]]))
        
        XCTAssertFalse(cond(parameters: ["a":1], condition: [["p":"a"], ["i":1], ["o":"pr"]]))
        XCTAssertFalse(cond(parameters: ["a":1.0], condition: [["p":"a"], ["f":1.0], ["o":"or"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"or"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"or"]]))
    }
    
    func test_evaluatesEqualityOperators() throws {
        XCTAssertTrue(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":false], ["o":"equal to"]]))
        
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":4], ["o":"equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":5], ["o":"equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":6], ["o":"equal to"]]))
        
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":4.0], ["o":"equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":5.0], ["o":"equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":6.0], ["o":"equal to"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"c"], ["o":"equal to"]]))
        
        XCTAssertFalse(cond(parameters: ["a":"2018-05-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-07-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"equal to"]]))
        
        
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"not equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":true], condition: [["p":"a"], ["b":false], ["o":"not equal to"]]))
        
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":4], ["o":"not equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":5], ["o":"not equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":6], ["o":"not equal to"]]))
        
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":4.0], ["o":"not equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":5.0], ["o":"not equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":6.0], ["o":"not equal to"]]))
        
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"not equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"c"], ["o":"not equal to"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"2018-05-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"not equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"not equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":"2018-07-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"not equal to"]]))
    }
    
    func test_evaluatesComparisonOperators() throws {
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":4], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":5], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":6], ["o":"greater than"]]))
        
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":4.0], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":5.0], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":6.0], ["o":"greater than"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-05-13T00:00:00.000Z"], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-07-13T00:00:00.000Z"], ["o":"greater than"]]))
        
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":4], ["o":"greater than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":5], ["o":"greater than eq"]]))
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":6], ["o":"greater than eq"]]))
        
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":4.0], ["o":"greater than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":5.0], ["o":"greater than eq"]]))
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":6.0], ["o":"greater than eq"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-05-13T00:00:00.000Z"], ["o":"greater than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"greater than eq"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-07-13T00:00:00.000Z"], ["o":"greater than eq"]]))
        
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":4], ["o":"less than"]]))
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":5], ["o":"less than"]]))
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":6], ["o":"less than"]]))
        
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":4.0], ["o":"less than"]]))
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":5.0], ["o":"less than"]]))
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":6.0], ["o":"less than"]]))
        
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-05-13T00:00:00.000Z"], ["o":"less than"]]))
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"less than"]]))
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-07-13T00:00:00.000Z"], ["o":"less than"]]))
        
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"a"], ["i":4], ["o":"less than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":5], ["o":"less than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":5], condition: [["p":"a"], ["i":6], ["o":"less than eq"]]))
        
        XCTAssertFalse(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":4.0], ["o":"less than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":5.0], ["o":"less than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":5.0], condition: [["p":"a"], ["f":6.0], ["o":"less than eq"]]))
        
        XCTAssertFalse(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-05-13T00:00:00.000Z"], ["o":"less than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-06-13T00:00:00.000Z"], ["o":"less than eq"]]))
        XCTAssertTrue(cond(parameters: ["a":"2018-06-13T00:00:00.000Z"], condition: [["p":"a"], ["t":"2018-07-13T00:00:00.000Z"], ["o":"less than eq"]]))
    }
    
    func test_evaluatesComparisonOperatorsAgainstIncompatibleTypes() throws {
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"greater than eq"]]))
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"less than"]]))
        XCTAssertFalse(cond(parameters: ["a":true], condition: [["p":"a"], ["b":true], ["o":"less than eq"]]))
        
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"greater than"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"greater than eq"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"less than"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"less than eq"]]))
    }
    
    func test_evaluatesStringComparisonOperators() throws {
        XCTAssertTrue(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"equal to"]]))
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"B"], ["o":"equal to"]]))
        
        XCTAssertFalse(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"b"], ["o":"not equal to"]]))
        XCTAssertTrue(cond(parameters: ["a":"b"], condition: [["p":"a"], ["s":"B"], ["o":"not equal to"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"O w"], ["o":"contains"]]))
        XCTAssertFalse(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"o W"], ["o":"contains"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"O w"], ["o":"contains ic"]]))
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"o W"], ["o":"contains ic"]]))
        XCTAssertFalse(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"oW"], ["o":"contains ic"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"HeLlO"], ["o":"starts with"]]))
        XCTAssertFalse(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"Hello"], ["o":"starts with"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"HeLlO"], ["o":"starts with ic"]]))
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"hElLo"], ["o":"starts with ic"]]))
        XCTAssertFalse(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"wOrLd"], ["o":"starts with ic"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"wOrLd"], ["o":"ends with"]]))
        XCTAssertFalse(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"WoRlD"], ["o":"ends with"]]))
        
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"wOrLd"], ["o":"ends with ic"]]))
        XCTAssertTrue(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"WoRlD"], ["o":"ends with ic"]]))
        XCTAssertFalse(cond(parameters: ["a":"HeLlO wOrLd"], condition: [["p":"a"], ["s":"HeLlO"], ["o":"ends with ic"]]))
        
    }
    
    func test_evaluatesComplexExpressions() throws {
        XCTAssertTrue(cond(parameters: ["a":10, "b":5, "c":"c", "d":true], condition: [["p":"c"], ["s":"p"],["o":"equal to"],["p":"a"],["i":"15"],["o":"less than"],["o":"and"],["p":"b"],["i":15],["o":"greater than eq"],["o":"and"],["p":"d"], ["b":true],["o":"equal to"],["o":"or"]]))
    }
    
    func test_failsOnMissingParameter() throws {
        XCTAssertFalse(cond(parameters: ["a":5], condition: [["p":"b"], ["i":5], ["o": "equal to"]]))
    }
    
    func test_failsOnMisMatchedParameterTypes() throws {
        // This doesn't work in objc AND Swift because it will happily convert 'b' to 0 and then carry on...
        XCTAssertTrue(cond(parameters: ["a":"b"], condition: [["p":"a"], ["i":5], ["o":"not equal to"]]))
    }
    
    func test_evaluatesCampaignTriggersAsExpected() {
        let campaignTriggerConfig: [String : Any] = [
            "showConditions": [
                ["executionsRequiredCount": "3"]
            ]
        ]
        let json = ["campaignExecutionConfig": campaignTriggerConfig]
        let trigger = DDNAEventTrigger(dictionary: json)!
        
        XCTAssertFalse(trigger.responds(toEventSchema: [:]))
        XCTAssertFalse(trigger.responds(toEventSchema: [:]))
        XCTAssertTrue(trigger.responds(toEventSchema: [:]))
    }
    
    private func cond(parameters: [AnyHashable:Any], condition: [[String:Any]]) -> Bool {
        let t: DDNAEventTrigger = DDNAEventTrigger(dictionary: ["condition" : condition])
        return t.responds(toEventSchema: ["eventParams": parameters])
    }

}
