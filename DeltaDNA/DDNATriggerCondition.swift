import Foundation

@objc public protocol DDNATriggerCondition {
    @objc func canExecute() -> Bool
}
