import NIO
import NIOHTTP1
import struct Foundation.Data

public struct HTTPResponse {
    public let head: HTTPResponseHead
    public let body: HTTPResponseBody?
    
    init(head: HTTPResponseHead, body: HTTPResponseBody?) {
        self.head = head
        self.body = body
    }
}

public enum HTTPResponseBody {
    case whole(Data)
    // TODO: chunks
}
