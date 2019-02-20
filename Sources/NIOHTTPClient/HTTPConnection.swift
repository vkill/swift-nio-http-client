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
            
            handlers.append(HTTPRequestEncoder())
            handlers.append(HTTPResponseDecoder())
            
            if case .https(_) = config.server.scheme {
                handlers.append(HTTPClientProxyHandler(connectionConfig: config))
            }
        } else {
            if case .https(let tlsHandler) = config.server.scheme {
                handlers.append(tlsHandler)
            }
            
            handlers.append(HTTPRequestEncoder())
            handlers.append(HTTPResponseDecoder())
        }
        
        // TODO
        
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
