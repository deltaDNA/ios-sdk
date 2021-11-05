import Foundation
@testable import DeltaDNA

class GeoIpNetworkClientMock: GeoIpNetworkClientProtocol {
    var responseToReturn: GeoIpResponse?
    var error: Error?
    
    func fetchGeoIpResponse(callback: @escaping (GeoIpResponse?, Error?) -> ()) {
        callback(responseToReturn, error)
    }
}
