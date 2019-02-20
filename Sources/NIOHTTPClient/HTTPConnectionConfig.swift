import NIO
import NIOOpenSSL

public struct HTTPConnectionConfig {
    public var server: HTTPConnectionServer
    public var proxy: HTTPConnectionProxy?
    
    public var connectTimeout: TimeAmount?
    
    public init(
        server: HTTPConnectionServer,
        proxy: HTTPConnectionProxy? = nil,
        connectTimeout: TimeAmount? = nil
    ) {
        self.server = server
        self.proxy = proxy
        self.connectTimeout = connectTimeout
    }
    
    public var isUsingProxy: Bool {
        return proxy != nil
    }
    
    public var socketHost: String {
        return proxy?.address ?? server.address
    }
    
    public var socketPort: Int {
        return proxy?.port ?? server.port
    }
}
