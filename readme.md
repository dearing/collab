# a live collaboration tool over a websocket #

- [CodeMirror](http://codemirror.net/) for all formating needs
- [Bootstrap](http://twitter.github.com/bootstrap/) for webpage scafolding
- Websocket routing wrtten in Go using JSON to move information between clients
- HTML5 local storage to keep persistent settings

## about ##
A live code collaboration tool is handy to have around, more so when you find yourself posting code snippets...
Nothing much to this really, the real work was already done with CodeMirror and Bootstrap - I just came in and 
stitched it all together.

- In order to use this effectively, you will need to run the binary on a visible network.
- For convenience, a built in webserver can handle the support files (SSL support off by default).
- This is not hardened software, do not expect support outside of development.
- Requires friends to use.
- Supports privately shared sessions with hashtags `http://myhost/#secret_poetry` for example.
- Visit the [download](https://github.com/dearing/collab/downloads) section for pre-built solutions {mac|linux|win}*{arm|amd64|x86}

![nothing fancy](https://raw.github.com/dearing/collab/master/www/img/collab.png)

## how to build ##
- [install go](http://golang.org/doc/install)
- fetch the source
- install websocket package
- build it

```
git clone https://github.com/dearing/collab.git
cd collab
go get code.google.com/p/go.net/websocket
go build

./collab --help
Usage of collab:
  -cert="": tls certificate
  -host=":8080": host to bind to
  -key="": tls certificate key
  -root="www/": webserver document root folder
  -tls=false: enable TLS
  -www=true: enable local webserver
```