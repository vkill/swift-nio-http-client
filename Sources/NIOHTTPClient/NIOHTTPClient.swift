import NIO

public struct NIOHTTPClient {
    
    private let eventLoopGroup: EventLoopGroup?
    
    public init(on eventLoopGroup: EventLoopGroup? = nil) {
        self.eventLoopGroup = eventLoopGroup
    }
    
    public func request(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        let promise = eventLoopGroup!.next().newPromise(of: HTTPResponse.self)
        // TODO
        return promise.futureResult
    }
}
