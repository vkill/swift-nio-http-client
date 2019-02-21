import NIO
import NIOHTTP1
import struct Foundation.Data
import NIOFoundationCompat

internal final class HTTPClientResponseDecoder: ChannelInboundHandler {
    typealias InboundIn = HTTPClientResponsePart
    typealias OutboundOut = HTTPResponse
    
    enum ResponseState {
        case ready
        case parsingBody(HTTPResponseHead, ByteBuffer?)
    }
    
    var state: ResponseState
    let config: HTTPConnectionConfig
    
    init(config: HTTPConnectionConfig) {
        self.state = .ready
        self.config = config
    }
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let res = self.unwrapInboundIn(data)
        switch res {
        case .head(let head):
            switch self.state {
            case .ready: self.state = .parsingBody(head, nil)
            case .parsingBody: assert(false, "Unexpected HTTPClientResponsePart.head when body was being parsed.")
            }
        case .body(var body):
            switch self.state {
            case .ready: assert(false, "Unexpected HTTPClientResponsePart.body when awaiting request head.")
            case .parsingBody(let head, let existingByteBuffer):
                let buffer: ByteBuffer
                if var existingByteBuffer = existingByteBuffer {
                    existingByteBuffer.write(buffer: &body)
                    buffer = existingByteBuffer
                } else {
                    buffer = body
                }
                self.state = .parsingBody(head, buffer)
            }
        case .end(let tailHeaders):
            assert(tailHeaders == nil, "Unexpected tail headers")
            switch self.state {
            case .ready: assert(false, "Unexpected HTTPClientResponsePart.end when awaiting request head.")
            case .parsingBody(let head, let byteBuffer):
                let body: HTTPResponseBody?
                if let byteBuffer = byteBuffer, let data = byteBuffer.getData(at: 0, length: byteBuffer.readableBytes) {
                    body = .whole(data)
                } else {
                    body = nil
                }
                
                let res = HTTPResponse(head: head, body: body)
                self.state = .ready
                ctx.fireChannelRead(wrapOutboundOut(res))
            }
        }
    }
}
