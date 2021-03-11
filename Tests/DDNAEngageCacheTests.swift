import XCTest
@testable import DeltaDNA

class DDNAEngageCacheTests: XCTestCase {
    let fileName = "EngageCache.plist"
    let defaultManager: FileManager = FileManager()
    
    var documentDirectory: String {
        let paths: Array<String> = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths[0].appending("/DeltaDNA").appending("/EngageCache.plist")
    }
    
    override func tearDownWithError() throws {
        try defaultManager.removeItem(atPath: documentDirectory)
    }
    
    func test_classInitialised_objectCreatedCorrectly() throws {
        let engageCache: DDNAEngageCache = DDNAEngageCache(path: fileName, expiryTimeInterval: 100)
        engageCache.setObject("Test Obj" as NSObject, forKey: "testKey")
       
        XCTAssertTrue(defaultManager.fileExists(atPath: documentDirectory))
    }
    
    func test_objectSaved_dataPersists() throws {
        let engageCache: DDNAEngageCache = DDNAEngageCache(path: fileName, expiryTimeInterval: 100)
        engageCache.setObject("Test Obj" as NSObject, forKey: "testKey")

        let engageCache2: DDNAEngageCache = DDNAEngageCache(path: fileName, expiryTimeInterval: 100)
        XCTAssertEqual(engageCache2.object(forKey: "testKey") as! String, "Test Obj")
    }
    
    func test_cacheCleared_dataNotPersists() throws {
        let engageCache: DDNAEngageCache = DDNAEngageCache(path: fileName, expiryTimeInterval: 100)
        engageCache.setObject("Test Obj" as NSObject, forKey: "testKey")
        
        engageCache.clear()
        XCTAssertTrue(defaultManager.fileExists(atPath: documentDirectory))
        XCTAssertNil(engageCache.object(forKey: "testKey"))
    }
    
    func test_expirationSetForCache_itemsExpireAfterSpecifiedTime() {
        let engageCache: DDNAEngageCache = DDNAEngageCache(path: fileName, expiryTimeInterval: 1)
        engageCache.setObject("Test Obj" as NSObject, forKey: "testKey")
        
        let _ = XCTWaiter.wait(for: [expectation(description: "Wait for 0.5 second")], timeout: 0.5)
        XCTAssertEqual(engageCache.object(forKey: "testKey") as! String, "Test Obj")
        let _ = XCTWaiter.wait(for: [expectation(description: "Wait for 1.5 seconds")], timeout: 1)
        XCTAssertNil(engageCache.object(forKey: "testKey"))
    }
    
    func test_expirationSetToZero_cacheIsDisabled() {
        let engageCache: DDNAEngageCache = DDNAEngageCache(path: fileName, expiryTimeInterval: 0)
        engageCache.setObject("Test Obj" as NSObject, forKey: "testKey")
        XCTAssertNil(engageCache.object(forKey: "testKey"))
    }
}
