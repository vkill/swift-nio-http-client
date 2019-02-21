import NIO
import NIOHTTP1
import struct Foundation.Data

public struct HTTPResponse {
    public let head: HTTPResponseHead
    public let body: Data?
    
    init(head: HTTPResponseHead, body: Data?) {
        self.head = head
        self.body = body
    }
    
    public var status: HTTPResponseStatus {
        return head.status
    }
}
