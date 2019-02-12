import NIO
import NIOHTTP1
import NIOOpenSSL
import struct Foundation.URL

fileprivate let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)

public struct NIOHTTPClientChannel {
    let channel: Channel
    
    public static func make(
        requestUrl: URL,
        requestTLSHandler: OpenSSLClientHandler? = nil,
        proxyUrl: URL? = nil,
        proxyTLSHandler: OpenSSLClientHandler? = nil,
        connectTimeout: TimeAmount = .seconds(10),
        eventLoopGroup: EventLoopGroup? = nil
    ) throws -> EventLoopFuture<NIOHTTPClientChannel> {
        let connectHost: String
        let connectPort: Int
        
        var handlers: [ChannelHandler] = []
        
        if let proxyUrl = proxyUrl {
            guard let host = proxyUrl.host else { fatalError() }
            connectHost = host
            
            let connectPortDefault: Int
            switch proxyUrl.scheme {
            case "http":
                connectPortDefault = 3128
            case "https":
                connectPortDefault = 3128
                
                if let proxyTLSHandler = proxyTLSHandler {
                    handlers.append(proxyTLSHandler)
                } else {
                    let tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
                    let sslContext = try SSLContext(configuration: tlsConfiguration)
                    let tlsHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: connectHost.isIPAddress() ? nil : connectHost)
                    
                    handlers.append(tlsHandler)
                }
            default:
                fatalError()
            }
            connectPort = proxyUrl.port ?? connectPortDefault
        } else {
            guard let host = requestUrl.host else { fatalError() }
            connectHost = host
            
            let connectPortDefault: Int
            switch requestUrl.scheme {
            case "http":
                connectPortDefault = 80
            case "https":
                connectPortDefault = 443
                
                if let requestTLSHandler = requestTLSHandler {
                    handlers.append(requestTLSHandler)
                } else {
                    let tlsConfiguration = TLSConfiguration.forClient(certificateVerification: .none)
                    let sslContext = try SSLContext(configuration: tlsConfiguration)
                    let tlsHandler = try OpenSSLClientHandler(context: sslContext, serverHostname: connectHost.isIPAddress() ? nil : connectHost)
                    
                    handlers.append(tlsHandler)
                }
            default:
                fatalError()
            }
            connectPort = requestUrl.port ?? connectPortDefault
        }
        
        //
        handlers.append(HTTPRequestEncoder())
        handlers.append(HTTPResponseDecoder())
        // TODO
        
        let bootstrap = ClientBootstrap(group: eventLoopGroup ?? group)
            .connectTimeout(connectTimeout)
            .channelInitializer { channel in
                return channel.pipeline.addHandlers(handlers, first: false)
            }
        
        return bootstrap.connect(host: connectHost, port: connectPort).map { channel in
            return .init(channel: channel)
        }
    }
    
    private init(channel: Channel) {
        self.channel = channel
    }
}
