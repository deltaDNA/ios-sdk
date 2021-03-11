import XCTest
@testable import DeltaDNA

class DDNAImageCacheTests: XCTestCase {
    let cacheDir: String = "ImageCache"
    var mockSession: UrlSessionMock!
    var imageCache: DDNAImageCache!
    var mockUrl: UrlMock!
    var mockUrl2: UrlMock!
    var testImage: UIImage!
    var testImage2: UIImage!
    let base64testImage: String = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg=="
    let base64testImage2: String = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII="
    let defaultManager: FileManager = FileManager()
    
    var documentDirectory: String? {
        let paths: [String] = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let firstElement = paths.first else {
            return nil
        }
        return firstElement.appending("/DeltaDNA").appending("/ImageCache")
    }
    
    override func setUpWithError() throws {
        mockSession = UrlSessionMock()
        imageCache = DDNAImageCache(urlSession: mockSession, cacheDir: cacheDir)
        
        mockUrl = UrlMock()
        mockUrl.lastPathComponentWillReturn = "test-image.png"
        mockUrl2 = UrlMock()
        mockUrl2.lastPathComponentWillReturn = "test-image2.png"
        
        testImage = UIImage(data: Data(base64Encoded: base64testImage, options: .ignoreUnknownCharacters)!)
        testImage2 = UIImage(data: Data(base64Encoded: base64testImage2, options: .ignoreUnknownCharacters)!)
    }
    
    override func tearDownWithError() throws {
        if let documentDirectoryExists = documentDirectory {
            try? defaultManager.removeItem(atPath: documentDirectoryExists)
        }
    }

    func test_setImage_addImageToCache() throws {
        let image: UIImage? = imageCache.image(for: mockUrl as URL?)
        XCTAssertNil(image)
        
        imageCache.setImage(testImage, for: mockUrl as URL?)
        guard let image2: UIImage = imageCache.image(for: mockUrl as URL?) else {
            return XCTFail()
        }
        
        XCTAssertEqual(image2.pngData(), testImage.pngData())
    }
    
    func test_requestImageForURL_fetchesFromCache() throws {
        imageCache.setImage(testImage, for: mockUrl as URL)
        var image2: UIImage? = nil
        let expectation = self.expectation(description: "imageCache.requestImage - Async call")
        
        imageCache.requestImage(for: mockUrl as URL, completionHandler: { image in
            image2 = image
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 0.1)

        guard let newImage = image2 else {
            return XCTFail()
        }
        XCTAssertEqual(newImage.pngData(), testImage.pngData())
        XCTAssertEqual(mockSession.downloadTaskCallCount, 0)
    }
    
    func test_requestImage_fetchAndStoreImageIfNotCached() throws {
        let image: UIImage? = imageCache.image(for: mockUrl as URL)
        XCTAssertNil(image)
        
        mockSession.downloadResponses.append((url: URL(string: "data:image/png;base64,\(base64testImage)")!, response: nil, error: nil))
        
        var image2: UIImage? = nil
        let exp = expectation(description: "Waited for completion handler for image2")
        imageCache.requestImage(for: mockUrl as URL?, completionHandler: { image in
            image2 = image
            exp.fulfill()
        })
        waitForExpectations(timeout: 0.1)

        guard let newImage = image2 else {
            return XCTFail()
        }
        XCTAssertEqual(newImage.pngData(), testImage.pngData())
        
        guard let image3: UIImage = imageCache.image(for: mockUrl as URL?) else {
            return XCTFail()
        }
        
        XCTAssertEqual(image3.pngData(), testImage.pngData())
    }
    
    func test_imageRequestFail_returnNil() throws {
        let image: UIImage? = imageCache.image(for: mockUrl as URL)
        XCTAssertNil(image)
    
        mockSession.downloadResponses.append((url: nil, response: nil, error: NSError(domain: "", code: 1001, userInfo: nil)))
        
        var image2: UIImage? = nil
        let exp = expectation(description: "Waited for completion handler for image2")
        
        imageCache.requestImage(for: mockUrl as URL?, completionHandler: { image in
            image2 = image
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 0.1)
        XCTAssertNil(image2)
    }
    
    func test_prefetchImages_allSuccessfulAvailableImmediately() throws {
        let image: UIImage? = imageCache.image(for: mockUrl as URL)
        XCTAssertNil(image)
        
        let testUrl: URL = URL(string: "data:image/png;base64,\(base64testImage)")!
        let testUrl2: URL = URL(string: "data:image/png;base64,\(base64testImage2)")!
        
        mockSession.downloadResponses.append((url: testUrl, response: nil, error: nil))
        mockSession.downloadResponses.append((url: testUrl2, response: nil, error: nil))
        
        let testUrls: [URL] = [mockUrl as URL, mockUrl2 as URL]
        var cached: Bool = false
        let exp = expectation(description: "Waited for completion handler for prefechImages")
        
        imageCache.prefechImages(for: testUrls, completionHandler: { downloaded, error in
            cached = true
            XCTAssertEqual(downloaded, testUrls.count)
            XCTAssertNil(error)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 0.1)
        XCTAssertTrue(cached)
        
        guard let image1: UIImage = imageCache.image(for: mockUrl as URL?) else {
            return XCTFail()
        }
        XCTAssertEqual(image1.pngData(), testImage.pngData())
        
        guard let image2: UIImage = imageCache.image(for: mockUrl2 as URL?) else {
            return XCTFail()
        }
        XCTAssertEqual(image2.pngData(), testImage2.pngData())
    }
    
    func test_prefetchImages_anyImageFails_reportOnce() throws {
        mockSession.downloadResponses.append((url: nil, response: nil, error: NSError(domain: "", code: 1001, userInfo: nil)))
        mockSession.downloadResponses.append((url: URL(string: "data:image/png;base64,\(base64testImage)")!, response: nil, error: nil))
        
        let testUrls: [URL] = [mockUrl as URL, mockUrl2 as URL]
        
        var called: Int = 0
        let exp = expectation(description: "Waited for completion handler for prefechImages")
        
        imageCache.prefechImages(for: testUrls, completionHandler: { downloaded, error in
            called += 1
            XCTAssertNotNil(error)
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(called, 1)
    }
}
