import NIO
import NIOHTTP1
import struct Foundation.Data

public struct HTTPRequest {
    public let head: HTTPRequestHead
    public let body: Data?
    
    public init(head: HTTPRequestHead, body: Data?) {
        self.head = head
        self.body = body
    }
    
    public init(
        method: HTTPMethod = .GET,
        uri: String,
        body: Data? = nil,
        headers: HTTPHeaders? = nil
    ) {
        var head = HTTPRequestHead(version: .init(major: 1, minor: 1), method: method, uri: uri)
        
        if let headers = headers {
            head.headers = headers
        }
        
        self.head = head
        
        self.body = body
    }
}
