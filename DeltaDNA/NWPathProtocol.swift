import Network

@available(iOS 12.0, *)
internal protocol NWPathProtocol {
    var status: NWPath.Status { get }
    var isExpensive: Bool { get }
}

@available(iOS 12.0, *)
extension NWPath: NWPathProtocol {}
