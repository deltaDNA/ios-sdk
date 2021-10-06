import Foundation

@objc public class DDNATriggerConditionParser: NSObject {
    let metricStore: DDNAEventTriggeredCampaignMetricStore
    let variantId: UInt
    
    @objc public init(metricStore: DDNAEventTriggeredCampaignMetricStore, variantId: UInt) {
        self.metricStore = metricStore
        self.variantId = variantId
    }
    
    @objc public func parse(fromJSON json: NSDictionary?) -> [DDNATriggerCondition] {
        guard let jsonDict = json else {
            NSLog("ETC trigger data missing, no triggers will be parsed.")
            return []
        }
        return convertJsonRepresentationToClasses(jsonData: jsonDict)
    }
    
    private func convertJsonRepresentationToClasses(jsonData: NSDictionary) -> [DDNATriggerCondition] {
        guard let showConditions = jsonData["showConditions"] as? [NSDictionary] else {
            NSLog("Missing show conditions from ETC trigger, trigger will not be parsed")
            return []
        }
        return showConditions.compactMap { conditionJson in
            if let requiredCountString = conditionJson["executionsRequiredCount"] as? String, let requiredCount = convertIntFromOptionalString(requiredCountString) {
                return DDNAExecutionCountTriggerCondition(
                    executionsRequiredCount: requiredCount,
                    metricStore: self.metricStore,
                    variantId: self.variantId
                )
            } else if let repeatCountString = conditionJson["executionsRepeat"] as? String, let repeatCount = convertIntFromOptionalString(repeatCountString) {
                return DDNAExecutionRepeatTriggerCondition(
                    repeatInterval: repeatCount,
                    repeatTimesLimit: convertIntFromOptionalString(conditionJson["executionsRepeatLimit"] as? String) ?? -1,
                    metricStore: self.metricStore,
                    variantId: self.variantId
                )
            } else {
                NSLog("Invalid format for ETC condition. Condition will not be checked")
                return nil
            }
        }
    }
    
    func convertIntFromOptionalString(_ stringToParse: String?) -> Int? {
        guard let nonOptionalString = stringToParse else {
            return nil
        }
        return Int(nonOptionalString)
    }
}
