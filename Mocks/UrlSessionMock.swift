class UrlSessionMock: NSURLSessionInterface {
    var downloadTaskCallCount: Int = 0
    var dataTaskCallCount: Int = 0
    var downloadResponses: [(url: URL?, response: URLResponse?, error: Error?)] = []
    var dataResponses: [(data: Data?, response: URLResponse?, error: Error?)] = []
    var nextDownloadTask = UrlSessionDownloadTaskMock()
    var nextDataTask = UrlSessionDataTaskMock()
    
    func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        if downloadResponses.isEmpty {
            completionHandler(nil, nil, nil)
        }
        completionHandler(downloadResponses[downloadTaskCallCount].url, downloadResponses[downloadTaskCallCount].response, downloadResponses[downloadTaskCallCount].error)
        downloadTaskCallCount += 1
        return nextDownloadTask as URLSessionDownloadTask
    }
    
    func dataTask(with request: URLRequest!, completionHandler: ((Data?, URLResponse?, Error?) -> Void)!) -> URLSessionDataTask! {
        if dataResponses.isEmpty {
            completionHandler(nil, nil, nil)
        }
        completionHandler(dataResponses[dataTaskCallCount].data, dataResponses[dataTaskCallCount].response, dataResponses[dataTaskCallCount].error)
        dataTaskCallCount += 1
        return nextDataTask as URLSessionDataTask
    }
    
    static func session(with configuration: URLSessionConfiguration!, delegate: URLSessionDelegate?, delegateQueue queue: OperationQueue?) -> URLSession! {
        return URLSession()
    }
}
