import Foundation

@objc public class DDNAExecutionRepeatTriggerCondition: NSObject, DDNATriggerCondition {
    let repeatInterval: Int
    let repeatTimesLimit: Int
    let metricStore: DDNAEventTriggeredCampaignMetricStoreProtocol
    let variantId: UInt

    init(repeatInterval: Int, repeatTimesLimit: Int, metricStore: DDNAEventTriggeredCampaignMetricStoreProtocol, variantId: UInt) {
        self.repeatInterval = repeatInterval
        self.repeatTimesLimit = repeatTimesLimit
        self.variantId = variantId
        self.metricStore = metricStore
    }

    @objc public func canExecute() -> Bool {
        let execCount = metricStore.getETCExecutionCount(variantId: variantId)
        
        let execCountIsOnInterval = execCount % repeatInterval == 0
        let thereIsNoRepeatLimit = repeatTimesLimit < 1
        let thereAreRepeatCountsRemaining = repeatTimesLimit * repeatInterval >= execCount
        
        return execCountIsOnInterval && (thereIsNoRepeatLimit || thereAreRepeatCountsRemaining)
    }
}
