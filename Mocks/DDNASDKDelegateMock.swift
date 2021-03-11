class DDNASDKDelegateMock: NSObject, DDNASDKDelegate {
    public var didFailToConfigureSessionWithErrorCalledCount: Int = 0
    public var didFailToConfigureSessionWithErrorArgumentCalled: Error? = nil
    public var didConfigureSessionCalledCount: Int = 0
    public var didFailToPopulateImageMessageCacheWithErrorCalledCount: Int = 0
    public var didPopulateImageMessageCacheCalledCount: Int = 0
    public var didConfigureSessionCacheArgumentCalled: Bool? = nil
    public var didStartSdkCalledCount: Int = 0
    public var didStopSdkCalledCount: Int = 0
    
    func didFailToConfigureSessionWithError(_ error: Error!) {
        didFailToConfigureSessionWithErrorCalledCount += 1
        didFailToConfigureSessionWithErrorArgumentCalled = error
        
    }
    
    func didConfigureSession(withCache cache: Bool) {
        didConfigureSessionCalledCount += 1
        didConfigureSessionCacheArgumentCalled = cache
    }
    
    func didFailToPopulateImageMessageCacheWithError(_ error: Error!) {
        didFailToPopulateImageMessageCacheWithErrorCalledCount += 1
    }
    
    func didPopulateImageMessageCache() {
        didPopulateImageMessageCacheCalledCount += 1
    }
    
    func didStartSdk() {
        didStartSdkCalledCount += 1
    }
    
    func didStopSdk() {
        didStopSdkCalledCount += 1
    }
}
