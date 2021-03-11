class DDNAActionStoreMock: DDNAActionStore {
    public var setParameterWasCalled: Bool = false
    public var parametersWasCalled: Bool = false
    public var removeWasCalled: Bool = false
    public var clearWasCalled: Bool = false
    public var willReturnParametersForTrigger: [String : Any]? = nil
    
    required override init(path: String = "") {
        super.init(path: path)
    }
    
    override func setParameters(_ parameters: [AnyHashable : Any]!, for trigger: DDNAEventTrigger!) {
        setParameterWasCalled = true
    }
    
    override func parameters(for trigger: DDNAEventTrigger!) -> [AnyHashable : Any]! {
        parametersWasCalled = true
        if let willReturnParametersForTrigger = willReturnParametersForTrigger {
            return willReturnParametersForTrigger
        }
        return super.parameters(for: trigger)
    }
    
    override func remove(for trigger: DDNAEventTrigger!) {
        removeWasCalled = true
    }
    
    override func clear() {
        clearWasCalled = true
    }
}
