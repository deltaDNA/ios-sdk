class DDNAUserManagerMock: DDNAUserManager {
    var willReturnAdvertisingId: String = ""
    var willReturnForgotten: Bool = false
    var willReturnDoNotTrack: Bool = false
    
    override var advertisingId: String! {
        get {
            return willReturnAdvertisingId
        }
        set {
            willReturnAdvertisingId = newValue
        }
    }
    
    override var forgotten: Bool {
        get {
            willReturnForgotten
        }
        set {
            willReturnForgotten = newValue
        }
    }
    override var doNotTrack: Bool {
        get {
            return willReturnDoNotTrack
        }
        set {
            willReturnDoNotTrack = newValue
        }
    }
}
