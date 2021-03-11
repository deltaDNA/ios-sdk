class DDNASDKMock: DDNASDK {
    public var willReturnUserID: String = ""
    public var willReturnSessionID: String = ""
    public var willReturnEngageURL: String? = nil
    public var requestWillUseEngagementHandler: DDNAEngagement?
    public var recordEventArgumentsCalled: [(eventName: String, eventParams: [AnyHashable : Any])] = []

    override var userID: String! {
        return willReturnUserID
    }
    
    override var sessionID: String! {
        return willReturnSessionID
    }
    
    override var engageURL: String! {
        if let willReturnEngageURL = willReturnEngageURL {
            return willReturnEngageURL
        }
        return super.engageURL
    }
    
    override func request(_ engagement: DDNAEngagement!, engagementHandler: ((DDNAEngagement?) -> Void)!) {
        return engagementHandler(requestWillUseEngagementHandler)
    }
    
    override func recordEvent(withName eventName: String!, eventParams: [AnyHashable : Any]!) -> DDNAEventAction! {
        recordEventArgumentsCalled.append((eventName: eventName, eventParams: eventParams))
        return super.recordEvent(withName: eventName, eventParams: eventParams)
    }
}
