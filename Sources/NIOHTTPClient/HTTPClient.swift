import NIO

public struct HTTPClient {
    private let connectionConfig: HTTPConnectionConfig
    private let eventLoopGroup: EventLoopGroup?
    
    public init(connectionConfig: HTTPConnectionConfig, on eventLoopGroup: EventLoopGroup? = nil) {
        self.connectionConfig = connectionConfig
        self.eventLoopGroup = eventLoopGroup
    }
    
    public func request(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        return HTTPConnection.start(config: connectionConfig).then { connection in
            return connection.request(req)
        }
    }
}
