import XCTest
@testable import DeltaDNA

class DDNAActionStoreTests: XCTestCase {

    var uut: DDNAActionStore!
    let defaultManager: FileManager = FileManager()
    
    override func setUpWithError() throws {
        let path = DDNA_ACTION_STORAGE_PATH.replacingOccurrences(of: "{persistent_path}", with: DDNASettings.getPrivateSettingsDirectoryPath())
        uut = DDNAActionStore(path: path)
    }
    
    override func tearDownWithError() throws {
        let path = DDNA_ACTION_STORAGE_PATH.replacingOccurrences(of: "{persistent_path}", with: DDNASettings.getPrivateSettingsDirectoryPath().appending("/ActionStore.plist"))
        if defaultManager.fileExists(atPath: path) {
            try defaultManager.removeItem(atPath: path)
        }
    }
    
    func test_pathPointsToNonexistentDirectory_directoryIsCreated() {
        let directoriesPaths: Array<String> = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)
        let documentDirectory: String = directoriesPaths[0].appending("/Test")
        var isDir = ObjCBool(true)
        
        XCTAssertFalse(defaultManager.fileExists(atPath: documentDirectory, isDirectory: &isDir))
        let _ = DDNAActionStore(path: documentDirectory)
        XCTAssertTrue(defaultManager.fileExists(atPath: documentDirectory))
        try? defaultManager.removeItem(atPath: documentDirectory)
    }

    func test_parametersAreSetForTrigger_correctParameterAreRetrieved() throws {
        let trigger = DDNAEventTriggerMock(dictionary: ["campaignID" : 1])
        let params: [String : Int] = ["a" : 1]
        
        XCTAssertNil(uut.parameters(for: trigger))
        uut.setParameters(params, for: trigger)
        XCTAssertEqual(uut.parameters(for: trigger) as! [String : Int], params)
    }
    
    func test_triggerContainsParameters_parametersAreCorrectlyRemovedFromTrigger() throws {
       let trigger = DDNAEventTriggerMock(dictionary: ["campaignID" : 1])
       let params: [String : Int] = ["a" : 1]
       
       XCTAssertNil(uut.parameters(for: trigger))
       uut.setParameters(params, for: trigger)
       uut.remove(for: trigger)
       XCTAssertNil(uut.parameters(for: trigger))
    }
    
    func test_triggerContainsParameters_ClearingRemovesParameters() throws {
        let trigger = DDNAEventTriggerMock(dictionary: ["campaignID" : 1])
        let params: [String : Int] = ["a" : 1]
        
        XCTAssertNil(uut.parameters(for: trigger))
        uut.setParameters(params, for: trigger)
        uut.clear()
        XCTAssertNil(uut.parameters(for: trigger))
    }

    func test_integration_changesArePersistent() throws {
        let trigger1 = DDNAEventTriggerMock(dictionary: ["campaignID" : 1])
        let trigger2 = DDNAEventTriggerMock(dictionary: ["campaignID" : 2])
        let trigger3 = DDNAEventTriggerMock(dictionary: ["campaignID" : 3])
        
        let params1: [String : Int] = ["a" : 1]
        let params2a: [String : Int] = ["a" : 2]
        let params2b: [String : Int] = ["b" : 2]
        let params3: [String : Int] = ["b" : 3]
        
        uut.setParameters(params1, for: trigger1)
        uut.setParameters(params2a, for: trigger2)
        uut.clear()
        uut.setParameters(params2b, for: trigger2)
        uut.setParameters(params3, for: trigger3)
        uut.remove(for: trigger2)

        XCTAssertNil(uut.parameters(for: trigger1))
        XCTAssertNil(uut.parameters(for: trigger2))
        XCTAssertEqual(uut.parameters(for: trigger3) as! [String : Int], params3)
    }
}
