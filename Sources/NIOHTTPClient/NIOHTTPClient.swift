import NIO

public struct NIOHTTPClient {
    private let config: NIOHTTPConnectionConfig
    private let eventLoopGroup: EventLoopGroup?
    
    public init(config: NIOHTTPConnectionConfig, on eventLoopGroup: EventLoopGroup? = nil) {
        self.config = config
        self.eventLoopGroup = eventLoopGroup
    }
    
    public func request(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        return NIOHTTPConnection.make(req: req, config: config).then { connection in
            return connection.send(req)
        }
    }
}
