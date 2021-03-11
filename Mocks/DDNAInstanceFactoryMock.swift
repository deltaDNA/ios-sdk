class DDNAInstanceFactoryMock: DDNAInstanceFactory {
    public var fakeNetworkRequest: DDNANetworkRequest?
    public var fakeEngageService: DDNAEngageService?
    public var fakeCollectService: DDNACollectService?

    override func buildNetworkRequest(with URL: URL!, jsonPayload: String!, delegate: DDNANetworkRequestDelegate!) -> DDNANetworkRequest! {
        guard let fakeNetworkRequest = fakeNetworkRequest else {
            return super.buildNetworkRequest(with: URL, jsonPayload: jsonPayload, delegate: delegate)
        }
        
        fakeNetworkRequest.delegate = delegate;
        return fakeNetworkRequest;
    }

    override func buildEngageService() -> DDNAEngageService {
        guard let fakeEngageService = fakeEngageService else {
            return super.buildEngageService()
        }
        
        return fakeEngageService
    }
    
    override func buildCollectService() -> DDNACollectService! {
        guard let fakeCollectService = fakeCollectService else {
            return super.buildCollectService()
        }
        
        return fakeCollectService
    }
}
