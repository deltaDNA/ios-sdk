import Network

@available(iOS 12.0, *)
internal protocol NWPathMonitorProtocol {
    var pathUpdateHandler: ((NWPath) -> Void)? { get set }
    func start(queue: DispatchQueue)
    func cancel()
    var queue: DispatchQueue? { get }
}

@available(iOS 12.0, *)
extension NWPathMonitor: NWPathMonitorProtocol {
}
