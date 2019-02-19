import NIO
import NIOHTTP1
import NIOOpenSSL
import struct Foundation.Data
import struct Foundation.URL

public struct HTTPRequest {
    public let head: HTTPRequestHead
    public let body: HTTPRequestBody?
    
    public var tlsHandler: OpenSSLClientHandler?
    public var proxy: HTTPProxy?

    public var isUsingProxy: Bool {
        return proxy != nil
    }
    
    public var headURL: URL {
        guard let url = URL(string: head.uri) else {
            fatalError()
        }
        return url
    }
    
    public var socketHost: String {
        if let proxy = proxy {
            return proxy.address
        } else {
            // TODO
            return headURL.host!
        }
    }
    
    public var socketPort: Int {
        if let proxy = proxy {
            return proxy.port
        } else {
            return headURL.port ?? (headURL.scheme == "https" ? 443 : 80)
        }
    }
}

public enum HTTPRequestBody {
    case whole(Data)
    // TODO: chunks
}
