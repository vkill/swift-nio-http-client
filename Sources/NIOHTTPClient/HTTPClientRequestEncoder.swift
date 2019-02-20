import NIO
import NIOHTTP1
import struct Foundation.Data
import struct Foundation.URLComponents

internal final class HTTPClientRequestEncoder: ChannelOutboundHandler {
    typealias OutboundIn = HTTPRequest
    typealias OutboundOut = HTTPClientRequestPart
    
    let connectionConfig: HTTPConnectionConfig
    
    init(connectionConfig: HTTPConnectionConfig) {
        self.connectionConfig = connectionConfig
    }
    
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let req = unwrapOutboundIn(data)
        
        var head = req.head
        
        let host = connectionConfig.server.isDefaultPort ? connectionConfig.server.address : "\(connectionConfig.server.address):\(connectionConfig.server.port)"
        head.headers.replaceOrAdd(name: "Host", value: host)
        
        head.headers.replaceOrAdd(name: "User-Agent", value: "NIOHTTPClient")
        
        guard var url = URLComponents(string: head.uri) else {
            fatalError()
        }
        if let _ = connectionConfig.proxy {
            if case .https(_) = connectionConfig.server.scheme {
                url.host = connectionConfig.server.address
                url.port = connectionConfig.server.port
            }
        }
        if !url.path.hasPrefix("/") {
            url.path = "/" + url.path
        }
        head.uri = url.url?.absoluteString ?? "/"
        
        ctx.write(wrapOutboundOut(.head(head)), promise: nil)
        
        if let body = req.body {
            switch body {
            case .whole(let data):
                var buffer = ByteBufferAllocator().buffer(capacity: data.count)
                buffer.write(bytes: data)
                ctx.write(self.wrapOutboundOut(.body(.byteBuffer(buffer))), promise: nil)
            }
        }

        ctx.write(self.wrapOutboundOut(.end(nil)), promise: promise)
    }
}
