import NIO

fileprivate let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public struct NIOHTTPConnectionConfig {
    public var connectTimeout: TimeAmount?
    
    public init(
        connectTimeout: TimeAmount?
    ) {
        self.connectTimeout = connectTimeout
    }
}

internal struct NIOHTTPConnection {
    public static func make(
        req: HTTPRequest,
        config: NIOHTTPConnectionConfig,
        eventLoopGroup: EventLoopGroup? = nil
    ) -> EventLoopFuture<NIOHTTPConnection> {
        var bootstrap = ClientBootstrap(group: eventLoopGroup ?? group)
        if let connectTimeout = config.connectTimeout {
            bootstrap = bootstrap.connectTimeout(connectTimeout)
        }
        
        // TODO
        
        return bootstrap.connect(host: req.socketHost, port: req.socketPort).map { channel in
            return .init(channel: channel)
        }
    }
    
    public var channel: Channel
    
    public init(
        channel: Channel
    ) {
        self.channel = channel
    }
    
    public func send(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let promise = self.channel.eventLoop.newPromise(of: HTTPResponse.self)
        self.channel.write(req, promise: nil)
        return promise.futureResult
    }
    
    public func close() -> EventLoopFuture<Void> {
        return channel.close(mode: .all)
    }
}
