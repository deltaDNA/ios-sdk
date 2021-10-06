import Foundation
@testable import DeltaDNA

class DDNAEventTriggeredCampaignMetricStoreMock: DDNAEventTriggeredCampaignMetricStoreProtocol {
    var currentETCCount: Int = 0
    
    func incrementETCExecutionCount(forVariantId variantId: UInt) {
        currentETCCount += 1
    }
    
    func getETCExecutionCount(variantId: UInt) -> Int {
        return currentETCCount
    }
}
