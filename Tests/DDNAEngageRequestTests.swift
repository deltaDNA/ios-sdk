import XCTest
@testable import DeltaDNA

class DDNAEngageRequestTests: XCTestCase {
    
    func test_noFlavourSpecified_requestIsBuildCorrectlyWithDefaultFlavour() throws {
       let request: DDNAEngageRequest = DDNAEngageRequest(decisionPoint: "testDecisionPoint", userId: "user-id-12345", sessionId: "session-id-12345")
       
       XCTAssertEqual(request.decisionPoint, "testDecisionPoint")
       XCTAssertEqual(request.flavour, "engagement")
       XCTAssertNil(request.parameters)
       XCTAssertEqual(request.userId, "user-id-12345")
       XCTAssertEqual(request.sessionId, "session-id-12345")
   }
   
   func test_customFlavourProvided_requestIsBuildCorrectly() throws {
       let request: DDNAEngageRequest = DDNAEngageRequest(decisionPoint: "testDecisionPoint", userId: "user-id-12345", sessionId: "session-id-12345")
       request.flavour = "advertising"
       request.parameters = ["hello" : "goodbye"]
       
       XCTAssertEqual(request.decisionPoint, "testDecisionPoint")
       XCTAssertEqual(request.flavour, "advertising")
       XCTAssertEqual(request.parameters.count, 1)
       XCTAssertEqual(request.parameters?["hello"] as? String, "goodbye")
       XCTAssertEqual(request.userId, "user-id-12345")
       XCTAssertEqual(request.sessionId, "session-id-12345")
   }
}
