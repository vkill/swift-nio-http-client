import NIO

public struct NIOHTTPClient {
    private let connectionConfig: NIOHTTPConnectionConfig
    private let eventLoopGroup: EventLoopGroup?
    
    public init(connectionConfig: NIOHTTPConnectionConfig, on eventLoopGroup: EventLoopGroup? = nil) {
        self.connectionConfig = connectionConfig
        self.eventLoopGroup = eventLoopGroup
    }
    
    public func request(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        return NIOHTTPConnection.start(config: connectionConfig).then { connection in
            return connection.request(req)
        }
    }
}
