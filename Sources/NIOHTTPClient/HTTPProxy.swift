import NIO
import NIOOpenSSL
import struct Foundation.URL

public enum HTTPProxyScheme {
    case http
    case https(OpenSSLClientHandler)
}

public enum HTTPProxyError: Error {
    case invalidHost
    case unsupportedScheme
}

public struct HTTPProxy {
    public static func make(
        url: URL,
        tlsHandler: OpenSSLClientHandler? = nil
    ) throws -> HTTPProxy {
        guard let host = url.host, !host.isEmpty else {
            throw HTTPProxyError.invalidHost
        }
        
        let scheme: HTTPProxyScheme
        let port: Int
        
        switch url.scheme {
        case "http":
            scheme = .http
            port = url.port ?? 3128
        case "https":
            if let tlsHandler = tlsHandler {
                scheme = .https(tlsHandler)
            } else {
                let tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
                let sslContext = try SSLContext(configuration: tlsConfiguration)
                let tlsHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: host.isIPAddress() ? nil : host)
                scheme = .https(tlsHandler)
            }
            
            port = url.port ?? 3128
        default:
            throw HTTPProxyError.unsupportedScheme
        }
        
        let username = url.user
        let password = url.password

        return .init(
            scheme: scheme,
            host: host,
            port: port,
            username: username,
            password: password
        )
    }
    
    //
    
    public let scheme: HTTPProxyScheme
    public let host: String
    public let port: Int
    public let username: String?
    public let password: String?

    public init(
        scheme: HTTPProxyScheme,
        host: String,
        port: Int,
        username: String? = nil,
        password: String? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.username = username
        self.password = password
    }
}
