class DDNACollectServiceMock: DDNACollectService, DDNANetworkRequestDelegate {
    var requestCalledCount: Int = 0
    var requestArgumentCalled: DDNACollectRequest? = nil
    var willReturnResponse: DDNACollectResponse? = nil
    
    override func request(_ request: DDNACollectRequest!, handler responseHandler: DDNACollectResponse!) {
        requestCalledCount += 1
        requestArgumentCalled = request
        super.request(request, handler: responseHandler)
    }
    
    var receivedRequest: DDNANetworkRequest? = nil
    var didReceiveResponse: String? = nil
    var didFailWithResponse: String? = nil
    var statusCode: Int? = nil
    var error: Error? = nil
    
    func request(_ request: DDNANetworkRequest!, didReceiveResponse response: String!, statusCode: Int) {
        receivedRequest = request
        self.didReceiveResponse = response
        self.statusCode = statusCode
    }
    
    func request(_ request: DDNANetworkRequest!, didFailWithResponse response: String!, statusCode: Int, error: Error!) {
        receivedRequest = request
        self.didFailWithResponse = response
        self.statusCode = statusCode
        self.error = error
    }
}

