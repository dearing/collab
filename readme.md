# a live collaboration tool over a websocket #

- [CodeMirror](http://codemirror.net/) for all formating needs
- [Bootstrap](http://twitter.github.com/bootstrap/) for webpage scafolding
- Websocket routing wrtten in Go using JSON to move information between clients
- HTML5 local storage to keep persistent settings

## about ##
I need from time to time a live source collaboration tool and I wasn't satisfied with what options I had around.
Nothing much to this really, the real work was already done with CodeMirror and Bootstrap - I just came in and 
stitched it all together.

- In order to use this effectively, you will need to run the binary on a visible network.
- For convenience, a built in webserver can handle the support files (SSL support off by default).
- This is not hardened software, do not expect support outside of development.
- Requires friends to use.
- Visit the [download](https://github.com/dearing/collab/downloads) section for a pre-built windows package

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