import NIO
import NIOHTTP1
import NIOOpenSSL
import struct Foundation.Data
import struct Foundation.URL

public struct HTTPRequest {
    public let head: HTTPRequestHead
    public let body: HTTPRequestBody?
}

public enum HTTPRequestBody {
    case whole(Data)
    // TODO: chunks
}
