class DDNAEventTriggerMock: DDNAEventTrigger {
    var expectedResponseToResponds: Bool = false
    var wasRespondsTriggered: Bool = false
    var willReturnActionType: String? = nil
    var willReturnResponse: [AnyHashable : Any]? = nil
    
    override func responds(toEventSchema eventSchema: [AnyHashable : Any]!) -> Bool {
        wasRespondsTriggered = true
        super.responds(toEventSchema: eventSchema)
        return expectedResponseToResponds
    }
    
    override var actionType: String! {
        if let willReturnActionType = willReturnActionType {
            return willReturnActionType
        }
        return super.actionType
    }
    
    override var response: [AnyHashable : Any]! {
        if let willReturnResponse = willReturnResponse {
            return willReturnResponse
        }
        return super.response
    }
}
