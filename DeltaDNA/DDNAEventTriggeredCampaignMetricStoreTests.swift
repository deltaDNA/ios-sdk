import Foundation
@testable import DeltaDNA
import XCTest

class DDNAEventTriggeredCampaignMetricStoreTests: XCTestCase {
    var metricStore: DDNAEventTriggeredCampaignMetricStore!
    
    let tempFilePath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("metricStoreTestTemp")
    
    override func setUp() {
        metricStore = DDNAEventTriggeredCampaignMetricStore(persistenceFilePath: tempFilePath)
    }
    
    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: tempFilePath.path) {
            try FileManager.default.removeItem(at: tempFilePath)
        }
    }
    
    func test_gettingTheCountOfAnUnknownVariant_returns0() {
        XCTAssertEqual(metricStore.getETCExecutionCount(variantId: 1), 0)
    }
    
    func test_incrementingAPreviouslyUnknownVariant_setsCountTo1() {
        metricStore.incrementETCExecutionCount(forVariantId: 1)
        
        XCTAssertEqual(metricStore.getETCExecutionCount(variantId: 1), 1)
    }
    
    func test_incrementingAPreviouslySetVariant_returnsTheCurrentCount() {
        metricStore.incrementETCExecutionCount(forVariantId: 1)
        metricStore.incrementETCExecutionCount(forVariantId: 1)
        
        XCTAssertEqual(metricStore.getETCExecutionCount(variantId: 1), 2)
    }
    
    func test_countsForVariantsShouldPersist() {
        metricStore.incrementETCExecutionCount(forVariantId: 1)
        metricStore.incrementETCExecutionCount(forVariantId: 1)
        
        // Delete the cached metric store to force rereading from disk
        metricStore = nil
        metricStore = DDNAEventTriggeredCampaignMetricStore(persistenceFilePath: tempFilePath)
        
        XCTAssertEqual(metricStore.getETCExecutionCount(variantId: 1), 2)
    }
}
