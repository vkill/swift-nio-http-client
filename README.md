# NIOHTTPClient

A description of this package.

## Test in Ubuntu 18.04

1. Install and verify tor

```
$ sudo apt install -y tor

$ sudo systemctl restart tor

$ sudo netstat -tunlp | grep tor
```

```
$ curl -x socks5://127.0.0.1:9050 https://httpbin.org/anything -v
```

2. Install and verify polipo

```
$ sudo apt install -y polipo

$ sudo mv /etc/polipo/config /etc/polipo/config.bak
$ sudo vim /etc/polipo/config
proxyAddress=127.0.0.1
proxyPort=8118
socksParentProxy=127.0.0.1:9050
socksProxyType=socks5

$ sudo systemctl restart polipo

$ sudo netstat -tunlp | grep polipo
```

```
$ curl -x http://127.0.0.1:8118 https://httpbin.org/anything -v
```

3. Install mkcert

```
$ wget https://github.com/FiloSottile/mkcert/releases/download/v1.3.0/mkcert-v1.3.0-linux-amd64
$ sudo mv mkcert-v1.3.0-linux-amd64 /usr/local/bin/mkcert
$ sudo chmod +x /usr/local/bin/mkcert

$ sudo mkcert -install
```

4. Install and verify nghttp2-proxy

```
$ sudo apt install -y nghttp2-proxy

$ mkcert localhost
$ sudo mv localhost-key.pem localhost.pem /etc/nghttpx/

$ sudo mv /etc/nghttpx/nghttpx.conf /etc/nghttpx/nghttpx.conf.bak
$ sudo vim /etc/nghttpx/nghttpx.conf
frontend=127.0.0.1,8443;tls
backend=127.0.0.1,8118;;no-tls
private-key-file=/etc/nghttpx/localhost-key.pem
certificate-file=/etc/nghttpx/localhost.pem
http2-proxy=yes
no-ocsp=yes

$ sudo systemctl restart nghttpx

$ sudo netstat -tunlp | grep nghttpx
```

```
$ curl -x https://localhost:8443 https://httpbin.org/anything -v
```

5. Run XCTest

```
$ git clone git@github.com:vkill/swift-nio-http-client.git
$ cd swift-nio-http-client

$ swift build
$ HTTP_PROXY_URL=http://127.0.0.1:8118 HTTPS_PROXY_URL=https://localhost:8443 swift test
```
