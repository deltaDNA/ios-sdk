class DDNAEngageServiceMock: DDNAEngageService {
    var requestCalledCount: Int = 0
    var requestArgumentCalled: DDNAEngageRequest? = nil
    var requestResponses: (response: String, statusCode: Int, error: Error?)? = nil
    
    override func request(_ request: DDNAEngageRequest!, handler responseHandler: DDNAEngageResponse!) {
        requestArgumentCalled = request
        requestCalledCount += 1
        guard let requestResponses = requestResponses else {
            return responseHandler(nil, 0, nil)
        }
        responseHandler(requestResponses.response, requestResponses.statusCode, requestResponses.error)
    }
}
