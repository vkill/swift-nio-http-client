import NIO
import NIOHTTP1
import struct Foundation.Data

public struct HTTPRequest {
    public let head: HTTPRequestHead
    public let body: HTTPRequestBody?
    
    public init(head: HTTPRequestHead, body: HTTPRequestBody?) {
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
        
        if let body = body {
            self.body = HTTPRequestBody.whole(body)
        } else {
            self.body = nil
        }
    }
}

public enum HTTPRequestBody {
    case whole(Data)
    // TODO: chunks
}
