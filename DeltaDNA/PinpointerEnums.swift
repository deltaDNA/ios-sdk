internal enum PinpointerEventName: String {
    case session = "unitySignalSession"
    case install = "unitySignalInstall"
    case purchase = "unitySignalPurchase"
}

internal enum PinpointerEventKey: String {
    case deviceName
    case userCountry
    case idfv
    case attTrackingStatus
    case idfa
    case limitedAdTracking
    case appStoreID
    case appBundleID
    case privacyPermissionAds
    case privacyPermissionExternal
    case privacyPermissionGameExp
    case privacyPermissionProfiling
    case privacyPermissionMethod
    case connectionType
    case appDeveloperID
    case realCurrencyAmount
    case realCurrencyType
    case transactionID
}
