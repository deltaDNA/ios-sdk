import XCTest
@testable import DeltaDNA

class DDNATriggerConditionParserTests: XCTestCase {
    var parser: DDNATriggerConditionParser!
    
    let variantId: UInt = 1
    
    override func setUp() {
        parser = DDNATriggerConditionParser(metricStore: DDNAEventTriggeredCampaignMetricStore.sharedInstance, variantId: 1)
    }
    
    override func tearDown() {
        parser = nil
    }
    
    func test_nilJsonReturnsEmptyArray() {
        let result = parser.parse(fromJSON: nil)
        XCTAssertTrue(result.isEmpty)
    }
    
    // Note: The ints in strings in these tests are intentional - the config payload arrives with these numbers as
    // strings, rather than integer values.
    
    func test_executionCountTriggerConditionsAreParsedSuccessfully() {
        let sampleJSON = ["showConditions": [["executionsRequiredCount": "3"]]] as NSDictionary
        let result = parser.parse(fromJSON: sampleJSON)
        guard let first = result.first as? DDNAExecutionCountTriggerCondition else {
            XCTFail("First item is not the right type, or is missing.")
            return
        }
        XCTAssertEqual(first.variantId, variantId)
        XCTAssertEqual(first.executionsRequiredCount, 3)
    }
    
    func test_executionRepeatTriggersWithoutARepeatLimitAreParsedSuccessfully() {
        let sampleJSON = ["showConditions": [["executionsRepeat": "3"]]] as NSDictionary
        let result = parser.parse(fromJSON: sampleJSON)
        guard let first = result.first as? DDNAExecutionRepeatTriggerCondition else {
            XCTFail("First item is not the right type, or is missing.")
            return
        }
        XCTAssertEqual(first.variantId, variantId)
        XCTAssertEqual(first.repeatInterval, 3)
        XCTAssertEqual(first.repeatTimesLimit, -1)
    }
    
    func test_executionRepeatTriggersWithARepeatLimitAreParsedSuccessfully() {
        let sampleJSON = ["showConditions": [["executionsRepeat": "3", "executionsRepeatLimit":"6"]]] as NSDictionary
        let result = parser.parse(fromJSON: sampleJSON)
        guard let first = result.first as? DDNAExecutionRepeatTriggerCondition else {
            XCTFail("First item is not the right type, or is missing.")
            return
        }
        XCTAssertEqual(first.variantId, variantId)
        XCTAssertEqual(first.repeatInterval, 3)
        XCTAssertEqual(first.repeatTimesLimit, 6)
    }
    
    func test_allTriggersAreParsedWhenThereAreMultipleTriggers() {
        let sampleJSON = ["showConditions": [["executionsRepeat": "3", "executionsRepeatLimit":"6"], ["executionsRequiredCount": "3"]]] as NSDictionary
        let result = parser.parse(fromJSON: sampleJSON)
        XCTAssertEqual(result.count, 2)
    }
    
    func test_invalidTriggersAreSkipped() {
        let sampleJSON = ["showConditions": [["executionsRepeat": "NaN", "executionsRepeatLimit":"hello"]]] as NSDictionary
        let result = parser.parse(fromJSON: sampleJSON)
        XCTAssertEqual(result.count, 0)
    }
}


