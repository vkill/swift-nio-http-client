import NIO
import NIOHTTP1
import struct Foundation.Data

final class HTTPClientProxyHandler: ChannelDuplexHandler {
    typealias InboundIn = HTTPClientResponsePart
    typealias OutboundIn = HTTPClientRequestPart
    typealias OutboundOut = HTTPClientRequestPart
    
    let config: HTTPConnectionConfig
    var onConnect: (ChannelHandlerContext) -> ()
    private var buffer: [HTTPClientRequestPart]
    
    var connected: Bool
    
    init(config: HTTPConnectionConfig, onConnect: @escaping (ChannelHandlerContext) -> ()) {
        assert(config.proxy != nil, "Should have proxy")
        self.config = config
        self.onConnect = onConnect
        self.buffer = []
        
        self.connected = false
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        if connected {
            return ctx.fireChannelRead(data)
        }
        
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            assert(head.status == .ok)
        case .body(_):
            _ = ""
        case .end:
            self.onConnect(ctx)
            
            self.buffer.forEach { ctx.write(self.wrapOutboundOut($0), promise: nil) }
            ctx.flush()
            
            self.connected = true
            
            _ = ctx.pipeline.remove(handler: self)
        }
    }
    
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let req = self.unwrapOutboundIn(data)
        
        if connected {
            ctx.writeAndFlush(self.wrapOutboundOut(req), promise: promise)
        } else {
            self.buffer.append(req)
            promise?.succeed(result: ())
        }
    }
    
    func channelActive(ctx: ChannelHandlerContext) {
        var head = HTTPRequestHead(
            version: .init(major: 1, minor: 1),
            method: .CONNECT,
            uri: "\(config.server.address):\(config.server.port)"
        )
        head.headers.replaceOrAdd(name: "Host", value: "\(config.server.address):\(config.server.port)")
        head.headers.replaceOrAdd(name: "User-Agent", value: "NIOHTTPClient")
        head.headers.replaceOrAdd(name: "Proxy-Connection", value: "Keep-Alive")
        guard let proxy = config.proxy else {
            fatalError()
        }
        if let username = proxy.username, let password = proxy.password {
            let base64String = Data("\(username):\(password)".utf8).base64EncodedString()
            head.headers.replaceOrAdd(name: "Authorization", value: "Basic \(base64String)")
        }
        
        ctx.write(self.wrapOutboundOut(.head(head)), promise: nil)
        ctx.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
    }
}
