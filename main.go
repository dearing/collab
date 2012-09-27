package main

import (
	"code.google.com/p/go.net/websocket"
	"flag"
	"fmt"
	"log"
	"net/http"
)

var host = flag.String("host", ":443", "host to bind to")
var root = flag.String("root", "www/", "webserver document root folder")
var cert = flag.String("cert", "cert.pem", "tls certificate")
var key = flag.String("key", "key.pem", "tls certificate key")
var useTLS = flag.Bool("tls", true, "enable TLS")
var useWWW = flag.Bool("www", true, "enable local webserver")

func main() {

	flag.Parse()
	mux := http.NewServeMux()

	// attach a fileserver to this mux
	if *useWWW {
		mux.Handle("/", http.FileServer(http.Dir(*root)))
	}

	// attach a static websocket at given url like "/mywebsocket"
	mux.Handle("/collab", websocket.Handler(WebsocketHandler))

	go Router.HandleClients()

	// HTTP
	if !*useTLS {
		fmt.Printf("listening on %s // root=%s\r\n", *host, *root)
		if err := http.ListenAndServe(*host, mux); err != nil {
			log.Printf("error : %v", err)
		}
	}

	// HTTPS
	if *useTLS {
		fmt.Printf("listening on %s // cert=%s, key=%s, root=%s\r\n", *host, *cert, *key, *root)
		if err := http.ListenAndServeTLS(*host, *cert, *key, mux); err != nil {
			log.Printf("error : %v", err)
		}
	}
}
