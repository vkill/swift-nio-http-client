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
}

public enum HTTPRequestBody {
    case whole(Data)
    // TODO: chunks
}
