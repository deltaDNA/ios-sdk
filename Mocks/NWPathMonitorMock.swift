import Network
@testable import DeltaDNA

@available(iOS 12.0, *)
internal class NWPathMonitorMock: NWPathMonitorProtocol {
    var startCalled: Bool = false
    var startQueue: DispatchQueue? = nil
    var cancelCalled: Bool = false
    
    var queue: DispatchQueue?
    var pathUpdateHandler: ((NWPath) -> Void)?
    
    func start(queue: DispatchQueue) {
        startCalled = true
        startQueue = queue
    }
    
    func cancel() {
        cancelCalled = true
    }
}
