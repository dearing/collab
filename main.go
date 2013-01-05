package main

import (
	"code.google.com/p/go.net/websocket"
	"flag"
	"log"
	"net/http"
)

var config Config
var conf = flag.String("conf", "collab.conf", "JSON configuration")
var gen = flag.Bool("gen", false, "generate default config")

func main() {

	flag.Parse()

	if *gen {
		config.GenerateConfig(*conf)
		return
	}

	config.LoadConfig(*conf)

	mux := http.NewServeMux()

	if config.EnableWWW {
		mux.Handle("/", http.FileServer(http.Dir(config.WWWRoot)))
	}

	mux.Handle(config.Tag, websocket.Handler(WebsocketHandler))
	go Router.HandleClients()

	// HTTP
	if !config.TLS {
		if config.Verbose {
			log.Printf("listening on %s\n", config.WWWHost)
		}
		if err := http.ListenAndServe(config.WWWHost, mux); err != nil {
			log.Println(err)
		}
	}

	// HTTPS
	if config.TLS {
		if config.Verbose {
			log.Printf("listening on %s // cert=%s, key=%s\n", config.WWWHost, config.Certificate, config.CertificateKey)
		}
		if err := http.ListenAndServeTLS(config.WWWHost, config.Certificate, config.CertificateKey, mux); err != nil {
			log.Println(err)
		}
	}
}
