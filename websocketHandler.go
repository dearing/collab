package main

import (
	"code.google.com/p/go.net/websocket"
)

func WebsocketHandler(ws *websocket.Conn) {

	client := &Client{
		Name:   "Client",
		Socket: ws,
	}

	Router.Add <- client

	client.Loop()
}
