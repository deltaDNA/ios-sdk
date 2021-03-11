import XCTest
@testable import DeltaDNA

class DDNAUserManagerTests: XCTestCase {
    
    let suiteName: String = "com.deltadna.test.UserManager"
    var userDefaults: UserDefaults!
    var userManager: DDNAUserManager!

    override func setUpWithError() throws {
        UserDefaults().removePersistentDomain(forName: suiteName)
        userDefaults = UserDefaults(suiteName: suiteName)
        userManager = DDNAUserManager(userDefaults: userDefaults)
    }

    func test_generateNewUserIdWithNil_cannotResertWithNil() throws {
        XCTAssertNil(userManager.userId)
        XCTAssertFalse(userManager.isNewPlayer)
        userManager.userId = nil
        
        let generatedUserId: String = userManager.userId
        XCTAssertNotNil(generatedUserId)
        XCTAssertTrue(userManager.isNewPlayer)
    }

    func test_usesPassedInUserId_cannotResetWithTheSameId() throws {
        XCTAssertNil(userManager.userId)
        XCTAssertFalse(userManager.isNewPlayer)
        userManager.userId = "user123"
        
        XCTAssertEqual(userManager.userId, "user123")
        XCTAssertTrue(userManager.isNewPlayer)
        
        userManager.userId = "user123"
        XCTAssertFalse(userManager.isNewPlayer)
    }
    
    func test_canChangeUserId_cannotResetWithDifferentId() throws {
        XCTAssertNil(userManager.userId)
        userManager.userId = nil
        XCTAssertTrue(userManager.isNewPlayer)
        
        userManager.userId = "user123"
        XCTAssertTrue(userManager.isNewPlayer)
    }
    
    func test_clearsPersistentData() throws {
        userManager.userId = "user123"
        
        XCTAssertEqual(userManager.userId, "user123")
        XCTAssertTrue(userManager.isNewPlayer)
        XCTAssertFalse(userManager.doNotTrack)
        XCTAssertFalse(userManager.forgotten)
        
        userManager.doNotTrack = true
        XCTAssertTrue(userManager.doNotTrack)
        userManager.forgotten = true
        XCTAssertTrue(userManager.forgotten)
        
        userManager.clearPersistentData()
        
        XCTAssertNil(userManager.userId)
        XCTAssertFalse(userManager.isNewPlayer)
        XCTAssertFalse(userManager.doNotTrack)
        XCTAssertFalse(userManager.forgotten)
    }
    
    func test_recordTheFirstSession() throws {
        XCTAssertNil(userManager.firstSession)
        let now: Date = Date()
        userManager.firstSession = now
        
        let userManager2: DDNAUserManager = DDNAUserManager(userDefaults: userDefaults)
        XCTAssertEqual(userManager2.firstSession, now)
    }
    
    func test_clearsTheFirstSession() throws {
        let now: Date = Date()
        userManager.firstSession = now
        XCTAssertEqual(userManager.firstSession, now)
        
        userManager.clearPersistentData()
        XCTAssertNil(userManager.firstSession)
    }
    
    func test_recordsTheLastSession() throws {
        XCTAssertNil(userManager.lastSession)
        let now: Date = Date()
        userManager.lastSession = now
        
        let userManager2: DDNAUserManager = DDNAUserManager(userDefaults: userDefaults)
        XCTAssertEqual(userManager2.lastSession, now)
    }
    
    func test_clearsTheLastSession() throws {
        let now: Date = Date()
        userManager.lastSession = now
        XCTAssertEqual(userManager.lastSession, now)
        
        userManager.clearPersistentData()
        XCTAssertNil(userManager.lastSession)
    }
    
    func test_returnsMsSinceFirstSession() throws {
        XCTAssertEqual(userManager.msSinceFirstSession(), 0)
        let firstSession: Date = Date(timeIntervalSinceNow: -10)
        userManager.firstSession = firstSession
        XCTAssertTrue(userManager.msSinceFirstSession() <= 10005)
        XCTAssertTrue(userManager.msSinceFirstSession() >= 9995)
    }
    
    func test_returnsMsSinceLastSession() throws {
        XCTAssertEqual(userManager.msSinceLastSession(), 0)
        let lastSession: Date = Date(timeIntervalSinceNow: -10)
        userManager.lastSession = lastSession
        XCTAssertTrue(userManager.msSinceLastSession() <= 10005)
        XCTAssertTrue(userManager.msSinceLastSession() >= 9995)
    }
    
    func test_recordsCrossGameUserId() throws {
        XCTAssertNil(userManager.crossGameUserId)
        userManager.crossGameUserId = "id"
        XCTAssertEqual(userManager.crossGameUserId, "id")
    }
    
    func test_clearsCrossGameUserId() throws {
        userManager.crossGameUserId = "id"
        userManager.clearPersistentData()
        XCTAssertNil(userManager.crossGameUserId)
    }
    
    func test_recordsAdversitingId() throws {
        XCTAssertNil(userManager.advertisingId)
        userManager.advertisingId = "123-ASDF-456"
        XCTAssertEqual(userManager.advertisingId, "123-ASDF-456")
    }
    
    func test_clearsAdversitingId() throws {
        userManager.advertisingId = "123-ASDF-456"
        userManager.clearPersistentData()
        XCTAssertNil(userManager.advertisingId)
    }
}
