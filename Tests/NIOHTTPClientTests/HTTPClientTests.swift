import XCTest
@testable import NIOHTTPClient

final class HTTPClientTests: XCTestCase {
    var proxy: HTTPConnectionProxy!
    
    var serverHTTPBin: HTTPConnectionServer!
    var serverHTTPBinTLS: HTTPConnectionServer!
    
    override func setUp() {
        guard let httpProxyURLString = ProcessInfo.processInfo.environment["HTTP_PROXY_URL"] else {
            fatalError()
        }
        guard let httpProxyURL = URL(string: httpProxyURLString) else {
            fatalError()
        }
        self.proxy = try! HTTPConnectionProxy.make(url: httpProxyURL)
        
        self.serverHTTPBin = try! HTTPConnectionServer.make(url: URL(string: "http://httpbin.org")!)
        self.serverHTTPBinTLS = try! HTTPConnectionServer.make(url: URL(string: "https://httpbin.org")!)
    }
    
    func testHTTPRequests() throws {
        let clientHTTPBin = HTTPClient.start(config: .init(server: serverHTTPBin))
        let clientHTTPBinTLS = HTTPClient.start(config: .init(server: serverHTTPBinTLS))
        
        XCTAssertEqual(try clientHTTPBin.wait().get(uri: "http://httpbin.org/status/200").wait().status, .ok)
        XCTAssertEqual(try clientHTTPBinTLS.wait().get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testHTTPSRequests() {
        let clientHTTPBin = HTTPClient.start(config: .init(server: serverHTTPBin, proxy: proxy))
        let clientHTTPBinTLS = HTTPClient.start(config: .init(server: serverHTTPBinTLS, proxy: proxy))
        
        XCTAssertEqual(try clientHTTPBin.wait().get(uri: "http://httpbin.org/status/200").wait().status, .ok)
        XCTAssertEqual(try clientHTTPBinTLS.wait().get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }

    static var allTests = [
        ("testHTTPRequests", testHTTPRequests),
        ("testHTTPRequestsViaProxy", testHTTPSRequests),
    ]
}
