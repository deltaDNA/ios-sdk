import Foundation

protocol DDNAEventTriggeredCampaignMetricStoreProtocol {
    func incrementETCExecutionCount(forVariantId variantId: UInt)
    func getETCExecutionCount(variantId: UInt) -> Int
}

@objc public class DDNAEventTriggeredCampaignMetricStore: NSObject, DDNAEventTriggeredCampaignMetricStoreProtocol {
    @objc public static let sharedInstance = DDNAEventTriggeredCampaignMetricStore()
    
    private let storePath: URL
    private var store: [String: Int] = [:]
    
    @objc public init(persistenceFilePath: URL = URL(fileURLWithPath: DDNASettings.getPrivateSettingsDirectoryPath()).appendingPathComponent("ddnaETCCountStore")) {
        storePath = persistenceFilePath
        
        super.init()
        
        readCountFromFile()
    }
    
    @objc public func incrementETCExecutionCount(forVariantId variantId: UInt) {
        let key = convertToKey(variantId)
        let previousValue = self.store[key] ?? 0
        self.store[key] = previousValue + 1
        self.writeCountToFile()
    }
    
    public func getETCExecutionCount(variantId: UInt) -> Int {
        return self.store[convertToKey(variantId)] ?? 0
    }
    
    func writeCountToFile() {
        do {
            let data = try JSONSerialization.data(withJSONObject: store, options: .init())
            try data.write(to: storePath)
        } catch {
            NSLog("Failed to write ETC count to file, campaign count has not been persisted.")
        }
    }
    
    func readCountFromFile() {
        do {
            if FileManager.default.fileExists(atPath: storePath.path) {
                let data = try Data(contentsOf: storePath)
                store = try (JSONSerialization.jsonObject(with: data, options: .init()) as? [String: Int]) ?? [:]
            } else {
                store = [:]
            }
        } catch {
            NSLog("Failed to read ETC count from file, campaign count has been reset.")
            store = [:]
        }
    }
    
    func convertToKey(_ intRepresentation: UInt) -> String {
        // Because deltaDNA uses UInts for keys here but Apple wants string keys to persist,
        // we need to convert it here. We can't use an array as we can't guarantee the Uints to
        // be in a particular range.
        return String(intRepresentation)
    }
}
