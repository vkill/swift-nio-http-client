import NIOOpenSSL
import struct Foundation.URL

public enum HTTPConnectionServerScheme {
    case http
    case https(OpenSSLClientHandler)
}

public enum HTTPConnectionServerError: Error {
    case invalidHost
    case unsupportedScheme
}

public struct HTTPConnectionServer {
    public static func make(
        url: URL,
        tlsHandler: OpenSSLClientHandler? = nil
    ) throws -> HTTPConnectionServer {
        guard let address = url.host, !address.isEmpty else {
            throw HTTPConnectionServerError.invalidHost
        }
        
        let scheme: HTTPConnectionServerScheme
        let port: Int
        
        switch url.scheme {
        case "http":
            scheme = .http
            port = url.port ?? 80
        case "https":
            if let tlsHandler = tlsHandler {
                scheme = .https(tlsHandler)
            } else {
                let tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
                let sslContext = try SSLContext(configuration: tlsConfiguration)
                let tlsHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: address.isIPAddress() ? nil : address)
                scheme = .https(tlsHandler)
            }
            
            port = url.port ?? 443
        default:
            throw HTTPConnectionServerError.unsupportedScheme
        }
        
        return .init(
            scheme: scheme,
            address: address,
            port: port
        )
    }
    
    //
    
    public let scheme: HTTPConnectionServerScheme
    public let address: String
    public let port: Int
}
