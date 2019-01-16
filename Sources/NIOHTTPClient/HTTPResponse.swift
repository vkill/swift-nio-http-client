import NIO
import NIOHTTP1
import struct Foundation.Data

public struct HTTPResponse {
    public let head: HTTPResponseHead
    public let body: HTTPResponseBody?
}

public enum HTTPResponseBody {
    case whole(Data)
    case chunks((Data) -> EventLoopFuture<Void>)
}
