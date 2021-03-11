import XCTest
@testable import DeltaDNA

class DDNAImageMessageTests: XCTestCase {

    var mockDelegate: DDNAImageMessageDelegateMock!
    
    override func setUpWithError() throws {
        mockDelegate = DDNAImageMessageDelegateMock()
    }

    override func tearDownWithError() throws {
      
    }

    func test_engagementIsNil_returnNil() throws {
        let imageMessage: DDNAImageMessage? = DDNAImageMessage(engagement: nil, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
    }
    
    func test_engagementIsInvalid_returnNil() throws {
        let engagement: DDNAEngagement = DDNAEngagement(decisionPoint: "testDecisionPoint")
        let imageMessage: DDNAImageMessage? = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
    }
    
    func test_imageKeyIsMissing_returnNil() throws {
        let engagement: DDNAEngagement = DDNAEngagement(decisionPoint: "testDecisionPoint")
        engagement.raw = "{\n\t\"transactionID\": 2184799313132298240,\n\t\"trace\": {\n\t\t\"initialState\": {\n\t\t\t\"serverNow\": 1460107947856000,\n\t\t\t\"userCreated\": 1459296000000000,\n\t\t\t\"roeLimited\": false\n\t\t},\n\t\t\"engagements\": [{\n\t\t\t\"engagementID\": 4451,\n\t\t\t\"behaviour\": 0,\n\t\t\t\"silent\": false,\n\t\t\t\"enabled\": true,\n\t\t\t\"parameterCriteria\": [],\n\t\t\t\"metricCriteria\": [],\n\t\t\t\"existingVariant\": 8800,\n\t\t\t\"existingState\": null,\n\t\t\t\"existingStateTimestamp\": null,\n\t\t\t\"existingConverted\": 0,\n\t\t\t\"parameters\": {\n\t\t\t\t\"adShowSession\": true\n\t\t\t}\n\t\t}]\n\t},\n\t\"parameters\": {\n\t\t\"adShowSession\": true,\n\t\t\"adProviders\": [{\n\t\t\t\"adProvider\": \"ADMOB\",\n\t\t\t\"eCPM\": 294,\n\t\t\t\"adUnitId\": \"ca-app-pub-4857093250239318/9840016386\"\n\t\t}],\n\t\t\"adRewardedProviders\": [{\n\t\t\t\"adProvider\": \"UNITY\",\n\t\t\t\"eCPM\": 1060,\n\t\t\t\"gameId\": \"106546\",\n\t\t\t\"testMode\": false\n\t\t}, {\n\t\t\t\"adProvider\": \"ADCOLONY\",\n\t\t\t\"eCPM\": 1323,\n\t\t\t\"appId\": \"appdd80fa453e784901bc\",\n\t\t\t\"clientOptions\": \"version:1.0,store:google\",\n\t\t\t\"zoneId\": \"vzc9a5567db2d447d29a\"\n\t\t}, {\n\t\t\t\"adProvider\": \"CHARTBOOST\",\n\t\t\t\"eCPM\": 38,\n\t\t\t\"appId\": \"56e3e633da15274fc8aa6cbf\",\n\t\t\t\"appSignature\": \"a7f6e1592a33abbcc0ac1e311d0ea1f614fefe7c\",\n\t\t\t\"location\": \"Default\"\n\t\t}, {\n\t\t\t\"adProvider\": \"VUNGLE\",\n\t\t\t\"eCPM\": 4,\n\t\t\t\"appId\": \"961178606\"\n\t\t}],\n\t\t\"adFloorPrice\": 1,\n\t\t\"adMinimumInterval\": 200,\n\t\t\"adMaxPerSession\": 20,\n\t\t\"adMaxPerNetwork\": 1,\n\t\t\"adDemoteOnRequestCode\": 1\n\t}\n}"
        
        let imageMessage: DDNAImageMessage? = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
    }
    
    func test_imageJsonIsInvalid_returnNil() throws {
        let engagement: DDNAEngagement = DDNAEngagement(decisionPoint: "testDecisionPoint")
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        var imageMessage: DDNAImageMessage? = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
        
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        imageMessage = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
        
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        imageMessage = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
        
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        imageMessage = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
        
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}}},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        imageMessage = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        XCTAssertNil(imageMessage)
    }
    
    func test_engagementIsValidWithParameters_returnImage() throws {
        let engagement: DDNAEngagement = DDNAEngagement(decisionPoint: "testDecisionPoint")
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{\"rewardName\":\"wrench\"}}"
        
        XCTAssertNotNil(engagement.json)
        XCTAssertTrue(engagement.json.keys.contains("image"))
        XCTAssertTrue(engagement.json.keys.contains("parameters"))
        
        let imageMessage: DDNAImageMessage = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        
        XCTAssertNotNil(imageMessage)
        XCTAssertFalse(imageMessage.isReady())
        XCTAssertFalse(imageMessage.isShowing())
        XCTAssertNotNil(imageMessage.parameters)
        XCTAssertEqual(imageMessage.parameters as NSDictionary, ["rewardName" : "wrench"] as NSDictionary)
    }
    
    func test_engagementIsValidWithoutParameters_returnImage() throws {
        let engagement: DDNAEngagement = DDNAEngagement(decisionPoint: "testDecisionPoint")
        engagement.raw = "{\"transactionID\":2184816393350012928,\"image\":{\"width\":512,\"height\":256,\"format\":\"png\",\"spritemap\":{\"background\":{\"x\":2,\"y\":38,\"width\":319,\"height\":177},\"buttons\":[{\"x\":2,\"y\":2,\"width\":160,\"height\":34},{\"x\":323,\"y\":180,\"width\":157,\"height\":35}]},\"layout\":{\"landscape\":{\"background\":{\"contain\":{\"halign\":\"center\",\"valign\":\"center\",\"left\":\"10%\",\"right\":\"10%\",\"top\":\"10%\",\"bottom\":\"10%\"},\"action\":{\"type\":\"none\",\"value\":\"\"}},\"buttons\":[{\"x\":-1,\"y\":144,\"action\":{\"type\":\"dismiss\",\"value\":\"\"}},{\"x\":160,\"y\":143,\"action\":{\"type\":\"action\",\"value\":\"reward\"}}]}},\"shim\":{\"mask\":\"dimmed\",\"action\":{\"type\":\"none\"}},\"url\":\"http://download.deltadna.net/engagements/3eef962b51f84f9ca21643ca21fb3057.png\"},\"parameters\":{}}"
        
        XCTAssertNotNil(engagement.json)
        XCTAssertTrue(engagement.json.keys.contains("image"))
        XCTAssertTrue(engagement.json.keys.contains("parameters"))
        
        let imageMessage: DDNAImageMessage = DDNAImageMessage(engagement: engagement, delegate: mockDelegate)
        
        XCTAssertNotNil(imageMessage)
        XCTAssertFalse(imageMessage.isReady())
        XCTAssertFalse(imageMessage.isShowing())
        XCTAssertNotNil(imageMessage.parameters)
        XCTAssertTrue(imageMessage.parameters.isEmpty)
    }
}

class DDNAImageMessageDelegateMock: NSObject, DDNAImageMessageDelegate {
    func didReceiveResources(for imageMessage: DDNAImageMessage!) {
    }
    
    func didFailToReceiveResources(for imageMessage: DDNAImageMessage!, withReason reason: String!) {
    }
    
    func onDismiss(_ imageMessage: DDNAImageMessage!, name: String!) {
    }
    
    func onActionImageMessage(_ imageMessage: DDNAImageMessage!, name: String!, type: String!, value: String!) {
    }
}
