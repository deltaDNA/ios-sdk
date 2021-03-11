protocol UrlSessionTaskProtocol {
    func resume()
}

extension URLSessionDownloadTask: UrlSessionTaskProtocol { }
extension URLSessionDataTask: UrlSessionTaskProtocol { }

class UrlSessionDownloadTaskMock: URLSessionDownloadTask {
    private (set) var resumeWasCalled = false

    override func resume() {
        resumeWasCalled = true
    }
}

class UrlSessionDataTaskMock: URLSessionDataTask {
    private (set) var resumeWasCalled = false

    override func resume() {
        resumeWasCalled = true
    }
}
