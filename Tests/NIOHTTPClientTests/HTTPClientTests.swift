import XCTest
@testable import NIOHTTPClient

final class HTTPClientTests: XCTestCase {
    var proxy: HTTPConnectionProxy!
    
    var serverHTTPBin: HTTPConnectionServer!
    var serverHTTPBinWithTLS: HTTPConnectionServer!
    
    override func setUp() {
        guard let httpProxyURLString = ProcessInfo.processInfo.environment["HTTP_PROXY_URL"] else {
            fatalError()
        }
        guard let httpProxyURL = URL(string: httpProxyURLString) else {
            fatalError()
        }
        self.proxy = try! HTTPConnectionProxy.make(url: httpProxyURL)
        
        self.serverHTTPBin = try! HTTPConnectionServer.make(url: URL(string: "http://httpbin.org")!)
        self.serverHTTPBinWithTLS = try! HTTPConnectionServer.make(url: URL(string: "https://httpbin.org")!)
    }
    
    func testHTTPRequests() throws {
        let clientHTTPBin = HTTPClient(connectionConfig: .init(server: serverHTTPBin))
        let clientHTTPBinWithTLS = HTTPClient(connectionConfig: .init(server: serverHTTPBinWithTLS))
        
        XCTAssertEqual(try clientHTTPBin.get(uri: "http://httpbin.org/status/200").wait().status, .ok)
        XCTAssertEqual(try clientHTTPBinWithTLS.get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testHTTPRequestsViaProxy() {
        let clientHTTPBin = HTTPClient(connectionConfig: .init(server: serverHTTPBin, proxy: proxy))
        let clientHTTPBinWithTLS = HTTPClient(connectionConfig: .init(server: serverHTTPBinWithTLS, proxy: proxy))
        
        XCTAssertEqual(try clientHTTPBin.get(uri: "http://httpbin.org/status/200").wait().status, .ok)
        XCTAssertEqual(try clientHTTPBinWithTLS.get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }

    static var allTests = [
        ("testHTTPRequests", testHTTPRequests),
        ("testHTTPRequestsViaProxy", testHTTPRequestsViaProxy),
    ]
}
