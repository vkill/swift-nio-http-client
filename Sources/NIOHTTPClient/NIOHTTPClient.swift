import NIO

public struct NIOHTTPClient {
    let channel: NIOHTTPClientChannel
    
    private init(
        channel: NIOHTTPClientChannel
    ) {
        self.channel = channel
    }
}

extension NIOHTTPClient {
}
