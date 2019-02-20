import NIO
import NIOHTTP1
import struct Foundation.Data

final class HTTPClientProxyHandler: ChannelDuplexHandler {
    typealias InboundIn = HTTPClientResponsePart
    typealias OutboundIn = HTTPClientRequestPart
    typealias OutboundOut = HTTPClientRequestPart
    
    let connectionConfig: HTTPConnectionConfig
    
    init(connectionConfig: HTTPConnectionConfig) {
        assert(connectionConfig.proxy != nil)
        self.connectionConfig = connectionConfig
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            assert(head.status == .ok)
        case .body(_):
            _ = ""
        case .end:
            _ = ctx.pipeline.remove(handler: self)
        }
    }
    
    func channelActive(ctx: ChannelHandlerContext) {
        var head = HTTPRequestHead(
            version: .init(major: 1, minor: 1),
            method: .CONNECT,
            uri: "\(connectionConfig.server.address):\(connectionConfig.server.port)"
        )
        head.headers.replaceOrAdd(name: "Host", value: "\(connectionConfig.server.address):\(connectionConfig.server.port)")
        head.headers.replaceOrAdd(name: "User-Agent", value: "NIOHTTPClient")
        head.headers.replaceOrAdd(name: "Proxy-Connection", value: "Keep-Alive")
        guard let proxy = connectionConfig.proxy else {
            fatalError()
        }
        if let username = proxy.username, let password = proxy.password {
            let base64String = Data("\(username):\(password)".utf8).base64EncodedString()
            head.headers.replaceOrAdd(name: "Authorization", value: "Basic \(base64String)")
        }
        
        ctx.write(self.wrapOutboundOut(.head(head)), promise: nil)
        ctx.write(self.wrapOutboundOut(.end(nil)), promise: nil)
        ctx.flush()
    }
}
