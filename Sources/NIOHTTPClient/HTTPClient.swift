import NIO
import NIOHTTP1
import struct Foundation.Data

public struct HTTPClient {
    public static func start(config: HTTPConnectionConfig, on eventLoopGroup: EventLoopGroup? = nil) -> EventLoopFuture<HTTPClient> {
        return HTTPConnection.start(config: config, eventLoopGroup: eventLoopGroup).map { connection in
            return self.init(connection: connection)
        }
    }
    
    public let connection: HTTPConnection
    
    public init(connection: HTTPConnection) {
        self.connection = connection
    }
    
    public func head(uri: String, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .HEAD, uri: uri, headers: headers)
        return self.request(req)
    }
    
    public func get(uri: String, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .GET, uri: uri, headers: headers)
        return self.request(req)
    }
    
    public func post(uri: String, body: Data?, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .POST, uri: uri, body: body, headers: headers)
        return self.request(req)
    }
    
    public func put(uri: String, body: Data?, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .PUT, uri: uri, body: body, headers: headers)
        return self.request(req)
    }
    
    public func delete(uri: String, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .DELETE, uri: uri, headers: headers)
        return self.request(req)
    }
    
    public func options(uri: String, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .OPTIONS, uri: uri, headers: headers)
        return self.request(req)
    }
    
    public func patch(uri: String, body: Data?, headers: HTTPHeaders? = nil) -> EventLoopFuture<HTTPResponse> {
        let req = HTTPRequest(method: .PATCH, uri: uri, body: body, headers: headers)
        return self.request(req)
    }
    
    public func request(_ req: HTTPRequest) -> EventLoopFuture<HTTPResponse> {
        return connection.request(req)
    }
}

internal final class HTTPClientContext {
    let request: HTTPRequest
    let promise: EventLoopPromise<HTTPResponse>
    
    init(request: HTTPRequest, promise: EventLoopPromise<HTTPResponse>) {
        self.request = request
        self.promise = promise
    }
}
