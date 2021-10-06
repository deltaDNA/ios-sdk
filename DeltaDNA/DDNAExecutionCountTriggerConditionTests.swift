import Foundation
import XCTest
@testable import DeltaDNA

class DDNAExecutionCountTriggerConditionTests: XCTestCase {
    var mockMetricStore: DDNAEventTriggeredCampaignMetricStoreMock!
    
    override func setUp() {
        mockMetricStore = DDNAEventTriggeredCampaignMetricStoreMock()
    }
    
    func test_ifNotEnoughExecutionsHaveOccurred_cannotExecute() {
        let condition = DDNAExecutionCountTriggerCondition(executionsRequiredCount: 3, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 1
        
        XCTAssertFalse(condition.canExecute())
    }
    
    func test_ifEnoughExecutionsHaveOccurred_canExecute() {
        let condition = DDNAExecutionCountTriggerCondition(executionsRequiredCount: 3, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 3
        
        XCTAssertTrue(condition.canExecute())
    }
    
    func test_ifTooManyExecutionsHaveOccurred_cannotExecute() {
        let condition = DDNAExecutionCountTriggerCondition(executionsRequiredCount: 3, metricStore: mockMetricStore, variantId: 1)
        
        mockMetricStore.currentETCCount = 5
        
        XCTAssertFalse(condition.canExecute())
    }
}
