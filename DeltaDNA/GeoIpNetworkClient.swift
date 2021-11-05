import Foundation

protocol GeoIpNetworkClientProtocol {
    func fetchGeoIpResponse(callback: @escaping (GeoIpResponse?, Error?) -> ())
}

struct GeoIpResponse: Codable {
    let identifier: String
    let country: String
    let region: String
    let ageGateLimit: Int
}

protocol URLSessionDataTaskProtocol {
    @discardableResult func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionDataTaskProtocol { }

@objc public class GeoIpNetworkClient: NSObject, GeoIpNetworkClientProtocol {
    
    let geoIpLookupServiceUrl = URL(string: "https://pls.prd.mz.internal.unity3d.com/api/v1/user-lookup")! // TODO
    let jsonDecoder = JSONDecoder()
    let urlSession: URLSessionDataTaskProtocol
    
    init(urlSession: URLSessionDataTaskProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchGeoIpResponse(callback: @escaping (GeoIpResponse?, Error?) -> ()) {
        urlSession.dataTask(with: geoIpLookupServiceUrl, completionHandler: { data, response, err in
            if let err = err {
                callback(nil, err)
                return
            }
            if let data = data {
                do {
                    let geoResponse: GeoIpResponse = try self.jsonDecoder.decode(GeoIpResponse.self, from: data)
                    callback(geoResponse, nil)
                    return
                } catch {
                    callback(nil, error)
                    return
                }
            } else {
                callback(nil, URLError(.badServerResponse))
            }
        }).resume()
    }
}
