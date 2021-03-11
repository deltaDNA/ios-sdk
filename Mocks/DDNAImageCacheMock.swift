@objc class DDNAImageCacheMock: DDNAImageCache {
    var requestImageWillReturn: UIImage? = UIImage()
    var requestImageCalledCount: Int = 0
    var prefechImageCompletionHandlerArgument: (Int, Error?)? = nil
    
    override public func image(for url: URL!) -> UIImage? {
        return requestImageWillReturn
    }
    
    override public func requestImage(for url: URL!, completionHandler: ((UIImage?) -> Void)!) {
        requestImageCalledCount += 1
        return completionHandler(requestImageWillReturn)
    }
    
    override public func prefechImages(for urls: [URL]!, completionHandler: ((Int, Error?) -> Void)!) {
        if let prefechImageCompletionHandlerArgument = prefechImageCompletionHandlerArgument {
            return completionHandler(prefechImageCompletionHandlerArgument.0, prefechImageCompletionHandlerArgument.1)
        }
        return super.prefechImages(for: urls, completionHandler: completionHandler)
    }
}
