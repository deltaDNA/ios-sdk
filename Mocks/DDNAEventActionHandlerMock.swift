class DDNAEventActionHandlerMock: NSObject, DDNAEventActionHandler {
    var typeReturn: String = ""
    var expectedHandleReturn: Bool = false
    var handleTriggerCountForValues: [[String : Any]] = []
    
    func type() -> String! {
        return typeReturn
    }
    
    func handle(_ eventTrigger: DDNAEventTrigger!, store: DDNAActionStore!) -> Bool {
        handleTriggerCountForValues.append(["eventTrigger" : eventTrigger!, "store" : store!])
        return expectedHandleReturn
    }
}
