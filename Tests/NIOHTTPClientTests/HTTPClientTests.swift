import XCTest
@testable import NIOHTTPClient

final class HTTPClientTests: XCTestCase {
    var proxyNonTLS: HTTPConnectionProxy!
    var proxyTLS: HTTPConnectionProxy!
    
    var serverNonTLSHTTPBin: HTTPConnectionServer!
    var serverTLSHTTPBin: HTTPConnectionServer!
    
    override func setUp() {
        guard let httpProxyURLString = ProcessInfo.processInfo.environment["HTTP_PROXY_URL"] else {
            fatalError()
        }
        guard let httpProxyURL = URL(string: httpProxyURLString) else {
            fatalError()
        }
        self.proxyNonTLS = try! HTTPConnectionProxy.make(url: httpProxyURL)
        
        guard let httpsProxyURLString = ProcessInfo.processInfo.environment["HTTPS_PROXY_URL"] else {
            fatalError()
        }
        guard let httpsProxyURL = URL(string: httpsProxyURLString) else {
            fatalError()
        }
        self.proxyTLS = try! HTTPConnectionProxy.make(url: httpsProxyURL)
        
        self.serverNonTLSHTTPBin = try! HTTPConnectionServer.make(url: URL(string: "http://httpbin.org")!)
        self.serverTLSHTTPBin = try! HTTPConnectionServer.make(url: URL(string: "https://httpbin.org")!)
    }
    
    func testServerNonTLSWithNonProxy() throws {
        let clientHTTPBin = try HTTPClient.start(config: .init(server: serverNonTLSHTTPBin, proxy: nil)).wait()
        XCTAssertEqual(try clientHTTPBin.get(uri: "http://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testServerNonTLSWithProxyNonTLS() throws {
        let clientHTTPBin = try HTTPClient.start(config: .init(server: serverNonTLSHTTPBin, proxy: proxyNonTLS)).wait()
        XCTAssertEqual(try clientHTTPBin.get(uri: "http://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testServerNonTLSWithProxyTLS() throws {
        let clientHTTPBin = try HTTPClient.start(config: .init(server: serverNonTLSHTTPBin, proxy: proxyTLS)).wait()
        XCTAssertEqual(try clientHTTPBin.get(uri: "http://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testServerTLSWithNonProxy() throws {
        let clientHTTPBin = try HTTPClient.start(config: .init(server: serverTLSHTTPBin, proxy: nil)).wait()
        XCTAssertEqual(try clientHTTPBin.get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testServerTLSWithProxyNonTLS() throws {
        let clientHTTPBin = try HTTPClient.start(config: .init(server: serverTLSHTTPBin, proxy: proxyNonTLS)).wait()
        XCTAssertEqual(try clientHTTPBin.get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }
    
    func testServerTLSWithProxyTLS() throws {
        let clientHTTPBin = try HTTPClient.start(config: .init(server: serverTLSHTTPBin, proxy: proxyTLS)).wait()
        XCTAssertEqual(try clientHTTPBin.get(uri: "https://httpbin.org/status/200").wait().status, .ok)
    }
    
    static var allTests = [
        ("testServerNonTLSWithNonProxy", testServerNonTLSWithNonProxy),
        ("testServerNonTLSWithProxyNonTLS", testServerNonTLSWithProxyNonTLS),
        ("testServerNonTLSWithProxyTLS", testServerNonTLSWithProxyTLS),
        ("testServerTLSWithNonProxy", testServerTLSWithNonProxy),
        ("testServerTLSWithProxyNonTLS", testServerTLSWithProxyNonTLS),
        ("testServerTLSWithProxyTLS", testServerTLSWithProxyTLS),
    ]
}
