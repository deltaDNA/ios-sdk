import XCTest
@testable import DeltaDNA

class DDNAEngageFactoryTests: XCTestCase {
    
    var mockSdk: DDNASDKMock!
    var engageFactory: DDNAEngageFactory!
    var fakeEngagement: DDNAEngagement!
    let decisionPoint: String = "testDecisionPoint"

    override func setUpWithError() throws {
        mockSdk = DDNASDKMock()
        engageFactory = DDNAEngageFactory(ddnasdk: mockSdk)
    }

    func test_engageFactory_requestsGameParameters() throws {
        fakeEngagement = DDNAEngagement(decisionPoint: decisionPoint)
        fakeEngagement.json = ["parameters" : [
                                "key1" : 5,
                                "key2" : 7 ]
        ]
        mockSdk.requestWillUseEngagementHandler = fakeEngagement
        
        engageFactory.requestGameParameters(forDecisionPoint: decisionPoint, handler: { gameParameters in
            XCTAssertNotNil(gameParameters)
            XCTAssertEqual(gameParameters.count, 2)
            XCTAssertEqual(gameParameters as NSDictionary, self.fakeEngagement.json["parameters"] as! NSDictionary)
        })
    }

    func test_engageFactory_returnsEmptyGameParametersWithInvalidEngagement() throws {
        fakeEngagement = DDNAEngagement(decisionPoint: decisionPoint)
        fakeEngagement.json = nil
        mockSdk.requestWillUseEngagementHandler = fakeEngagement
        
        engageFactory.requestGameParameters(forDecisionPoint: decisionPoint, handler: { gameParameters in
            XCTAssertNotNil(gameParameters)
            XCTAssertEqual(gameParameters.count, 0)
            XCTAssertTrue(gameParameters.isEmpty)
        })
    }
    
    func test_engageFactory_requestsImageMessage() throws {
        fakeEngagement = DDNAEngagement(decisionPoint: decisionPoint)
        fakeEngagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        mockSdk.requestWillUseEngagementHandler = fakeEngagement
        
        engageFactory.requestImageMessage(forDecisionPoint: decisionPoint, handler: { imageMessage in
            XCTAssertNotNil(imageMessage)
            XCTAssertNotNil(imageMessage?.parameters)
            XCTAssertEqual(imageMessage?.parameters.count, 1)
            XCTAssertEqual(imageMessage?.parameters as? [String : String], ["rewardName": "wrench"])
        })
    }

    func test_engageFactory_requestsImageMessage_imageMessageIsNil() throws {
        fakeEngagement = DDNAEngagement(decisionPoint: decisionPoint)
        fakeEngagement.json = nil
        mockSdk.requestWillUseEngagementHandler = fakeEngagement
        
        engageFactory.requestImageMessage(forDecisionPoint: decisionPoint, handler: { imageMessage in
            XCTAssertNil(imageMessage)
        })
    }
}
