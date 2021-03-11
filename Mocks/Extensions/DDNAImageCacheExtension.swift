internal extension DDNAImageCache {
    @objc class func sharedInstanceMockWithImage() -> DDNAImageCache! {
        let mock = DDNAImageCacheMock(urlSession: UrlSessionMock(), cacheDir: "Mock")!
        mock.requestImageWillReturn = UIImage()
        return mock as DDNAImageCache
    }
    
    @objc class func sharedInstanceMockNoImage() -> DDNAImageCache! {
        let mock = DDNAImageCacheMock(urlSession: UrlSessionMock(), cacheDir: "")!
        mock.requestImageWillReturn = nil
        return mock as DDNAImageCache
    }
    
    @objc class func sharedInstancePrefetchImagesUrls() -> DDNAImageCache! {
        let mock = DDNAImageCacheMock(urlSession: UrlSessionMock(), cacheDir: "")!
        mock.prefechImageCompletionHandlerArgument = (2, nil)
        return mock as DDNAImageCache
    }
    
    @objc class func sharedInstancePrefetchImagesError() -> DDNAImageCache! {
        let mock = DDNAImageCacheMock(urlSession: UrlSessionMock(), cacheDir: "")!
        mock.prefechImageCompletionHandlerArgument = (0, NSError(domain: "", code: 0, userInfo: nil))
        return mock as DDNAImageCache
    }
}
