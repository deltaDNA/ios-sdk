class DDNANetworkRequestMock: DDNANetworkRequest {
    public var data: Data = Data()
    public var response: URLResponse?
    public var error: NSError?
    
    convenience init(with Url: String, data: NSString?, statusCode: NSInteger, error: NSError?) {
        self.init()
        if let data = data {
            self.data = data.data(using: String.Encoding.utf8.rawValue)!
        }
        self.response = HTTPURLResponse(url: URL(fileURLWithPath: Url), statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
        self.error = error
    }

    override func send() {
        NSLog("I'm a fake network request")
        super.handleResponse(self.data, response: self.response, error: self.error)
    }
}
