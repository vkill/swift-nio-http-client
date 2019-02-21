import NIO
import NIOHTTP1
import struct Foundation.Data
import struct Foundation.URLComponents

internal final class HTTPClientRequestEncoder: ChannelOutboundHandler {
    typealias OutboundIn = HTTPRequest
    typealias OutboundOut = HTTPClientRequestPart
    
    let config: HTTPConnectionConfig
    
    init(config: HTTPConnectionConfig) {
        self.config = config
    }
    
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let req = unwrapOutboundIn(data)
        
        var head = req.head
        
        let host = config.server.isDefaultPort ? config.server.address : "\(config.server.address):\(config.server.port)"
        head.headers.replaceOrAdd(name: "Host", value: host)
        
        head.headers.replaceOrAdd(name: "User-Agent", value: "NIOHTTPClient")
        
        guard var urlComponents = URLComponents(string: head.uri) else {
            assert(false, "invalid head.uri \(head.uri)")
        }
        if let _ = config.proxy {
            if case .https(_) = config.server.scheme {
                urlComponents.host = config.server.address
                urlComponents.port = config.server.port
            }
        }
        if !urlComponents.path.hasPrefix("/") {
            urlComponents.path = "/" + urlComponents.path
        }
        guard let url = urlComponents.url else {
            assert(false, "convert URLComponents to URL failed")
        }
        head.uri = url.absoluteString
        
        ctx.write(wrapOutboundOut(.head(head)), promise: nil)
        
        if let body = req.body {
            var buffer = ByteBufferAllocator().buffer(capacity: body.count)
            buffer.write(bytes: body)
            ctx.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
        }

        ctx.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: promise)
    }
}
