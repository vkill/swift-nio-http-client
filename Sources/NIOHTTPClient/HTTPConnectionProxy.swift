import NIOOpenSSL
import struct Foundation.URL

public enum HTTPConnectionProxyScheme {
    case http
    case https(OpenSSLClientHandler)
}

public enum HTTPConnectionProxyError: Error {
    case invalidHost
    case unsupportedScheme
}

public struct HTTPConnectionProxy {
    public static func make(
        url: URL,
        tlsHandler: OpenSSLClientHandler? = nil
    ) throws -> HTTPConnectionProxy {
        guard let address = url.host, !address.isEmpty else {
            throw HTTPConnectionProxyError.invalidHost
        }
        
        let scheme: HTTPConnectionProxyScheme
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
                let tlsHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: address.isIPAddress() ? nil : address)
                scheme = .https(tlsHandler)
            }
            
            port = url.port ?? 3128
        default:
            throw HTTPConnectionProxyError.unsupportedScheme
        }
        
        let username = url.user
        let password = url.password

        return .init(
            scheme: scheme,
            address: address,
            port: port,
            username: username,
            password: password
        )
    }
    
    //
    
    public let scheme: HTTPConnectionProxyScheme
    public let address: String
    public let port: Int
    public let username: String?
    public let password: String?
}
