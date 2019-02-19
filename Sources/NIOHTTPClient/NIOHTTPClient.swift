import NIO

public struct NIOHTTPClient {
    
    private let eventLoopGroup: EventLoopGroup?
    
    public init(on eventLoopGroup: EventLoopGroup? = nil) {
        self.eventLoopGroup = eventLoopGroup
    }
    
    public func request(_ req: HTTPRequest, config: NIOHTTPConnectionConfig) -> EventLoopFuture<HTTPResponse> {
        return NIOHTTPConnection.make(req: req, config: config).then { connection in
            return connection.send(req)
        }
    }
}
