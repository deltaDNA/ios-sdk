import Foundation
import XCTest
@testable import DeltaDNA

class DDNAExecutionRepeatTriggerConditionTests: XCTestCase {
    var mockMetricStore: DDNAEventTriggeredCampaignMetricStoreMock!
    
    override func setUp() {
        mockMetricStore = DDNAEventTriggeredCampaignMetricStoreMock()
    }
    
    func test_ifCountIsNotOnRepeatInterval_cannotExecute() {
        let condition = DDNAExecutionRepeatTriggerCondition(repeatInterval: 3, repeatTimesLimit: -1, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 1
        
        XCTAssertFalse(condition.canExecute())
    }
    
    func test_ifCountIsOnRepeatInterval_AndHasANegativeLimit_canExecute() {
        let condition = DDNAExecutionRepeatTriggerCondition(repeatInterval: 3, repeatTimesLimit: -1, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 3
        
        XCTAssertTrue(condition.canExecute())
    }
    
    func test_ifCountIsOnRepeatInterval_AndHasALimit_ButLimitIsNotReached_canExecute() {
        let condition = DDNAExecutionRepeatTriggerCondition(repeatInterval: 3, repeatTimesLimit: 3, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 6
        
        XCTAssertTrue(condition.canExecute())
    }
    
    func test_ifCountIsOnRepeatInterval_AndHasALimit_ButLimitIsExceeded_cannotExecute() {
        let condition = DDNAExecutionRepeatTriggerCondition(repeatInterval: 3, repeatTimesLimit: 3, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 12
        
        XCTAssertFalse(condition.canExecute())
    }
}
