import NIO
import NIOOpenSSL

public struct NIOHTTPConnectionConfig {
    public var connectTimeout: TimeAmount?
    
    public init(
        connectTimeout: TimeAmount?
        ) {
        self.connectTimeout = connectTimeout
    }
}
