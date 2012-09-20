package main

import (
	"code.google.com/p/go.net/websocket"
	"flag"
	"fmt"
	"log"
	"net/http"
)

var host = flag.String("host", ":8080", "host to bind to")
var root = flag.String("root", "www/", "webserver document root folder")
var cert = flag.String("cert", "", "tls certificate")
var key = flag.String("key", "", "tls certificate key")
var useTLS = flag.Bool("tls", false, "enable TLS")
var useWWW = flag.Bool("www", true, "enable local webserver")

func main() {

	flag.Parse()
	mux := http.NewServeMux()
	if *useWWW {
		mux.Handle("/", http.FileServer(http.Dir(*root)))
	}

	mux.Handle("/collab", websocket.Handler(WebsocketHandler))

	go R.HandleClients()

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
