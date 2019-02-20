import NIO
import NIOHTTP1

fileprivate let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

internal struct HTTPConnection {
    public static func start(
        config: HTTPConnectionConfig,
        eventLoopGroup: EventLoopGroup? = nil
    ) -> EventLoopFuture<HTTPConnection> {
        var bootstrap = ClientBootstrap(group: eventLoopGroup ?? group)
        if let connectTimeout = config.connectTimeout {
            bootstrap = bootstrap.connectTimeout(connectTimeout)
        }
        
        var handlers: [ChannelHandler] = []
        if let proxy = config.proxy {
            if case .https(let tlsHandler) = proxy.scheme {
                handlers.append(tlsHandler)
            }
            
            let httpReqEncoder = HTTPRequestEncoder()
            handlers.append(httpReqEncoder)
            
            let httpResDecoder = HTTPResponseDecoder()
            handlers.append(httpResDecoder)
            
            if case .https(let tlsHandler) = config.server.scheme {
                let proxyHandler = HTTPClientProxyHandler(connectionConfig: config) { ctx in
                    _ = ctx.pipeline.add(handler: tlsHandler, before: httpReqEncoder)
                }
                handlers.append(proxyHandler)
            }
        } else {
            if case .https(let tlsHandler) = config.server.scheme {
                handlers.append(tlsHandler)
            }
            
            let httpReqEncoder = HTTPRequestEncoder()
            handlers.append(httpReqEncoder)
            
            let httpResDecoder = HTTPResponseDecoder()
            handlers.append(httpResDecoder)
        }
        
        let httpClientReqEncoder = HTTPClientRequestEncoder(connectionConfig: config)
        handlers.append(httpClientReqEncoder)
        
        let httpClientResDecoder = HTTPClientResponseDecoder(connectionConfig: config)
        handlers.append(httpClientResDecoder)
        
        
        bootstrap = bootstrap.channelInitializer { channel in
                return channel.pipeline.addHandlers(handlers, first: false)
        }
        
        return bootstrap.connect(host: config.socketHost, port: config.socketPort).map { channel in
            return .init(channel: channel)
        }
    }
    
    public var channel: Channel
    
    public init(
        channel: Channel
    ) {
        self.channel = channel
    }
    
    public func request(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let promise = self.channel.eventLoop.newPromise(of: HTTPResponse.self)
        self.channel.write(req, promise: nil)
        return promise.futureResult
    }
    
    public func close() -> EventLoopFuture<Void> {
        return channel.close(mode: .all)
    }
}
