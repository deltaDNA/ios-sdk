import Foundation

@objc public class DDNAExecutionCountTriggerCondition: NSObject, DDNATriggerCondition {
    let executionsRequiredCount: Int
    let metricStore: DDNAEventTriggeredCampaignMetricStoreProtocol
    let variantId: UInt
    
    init(executionsRequiredCount: Int, metricStore: DDNAEventTriggeredCampaignMetricStoreProtocol, variantId: UInt) {
        self.executionsRequiredCount = executionsRequiredCount
        self.variantId = variantId
        self.metricStore = metricStore
    }
    
    @objc public func canExecute() -> Bool {
        return executionsRequiredCount == metricStore.getETCExecutionCount(variantId: variantId)
    }
}
