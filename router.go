package main

import (
	"code.google.com/p/go.net/websocket"
	"crypto/sha1"
	"fmt"
	"time"
)

type router struct {
	Add       chan *Client
	Remove    chan *Client
	Echo      chan *ClientJSON
	Broadcast chan *Message
	Send      chan *Message
	Clients   map[*Client]bool
	GetID     chan string
}

var Router = router{
	Add:       make(chan *Client),
	Remove:    make(chan *Client),
	Echo:      make(chan *ClientJSON),
	Broadcast: make(chan *Message),
	Send:      make(chan *Message),
	Clients:   make(map[*Client]bool),
	GetID:     make(chan string),
}

type Message struct {
	Client *Client
	JSON   *ClientJSON
}

// await work on a channel
func (Router *router) HandleClients() {

	// borrowed from cloudflare : http://blog.cloudflare.com/go-at-cloudflare
	go func() {
		h := sha1.New()
		for {
			h.Write([]byte(time.Now().String()))
			Router.GetID <- fmt.Sprintf("%X", h.Sum(nil))
		}
	}()

	for {
		select {

		// ADD
		case client := <-Router.Add:
			Router.Clients[client] = true

		// REMOVE
		case client := <-Router.Remove:
			client.Socket.Close()
			delete(Router.Clients, client)

		// ECHO
		case Data := <-Router.Echo:
			for client := range Router.Clients {
				websocket.JSON.Send(client.Socket, Data)
			}

		// BROADCAST (!CLIENT)
		case message := <-Router.Broadcast:
			for peer := range Router.Clients {
				if peer != message.Client {
					websocket.JSON.Send(peer.Socket, message.JSON)
				}
			}

		// SEND
		case message := <-Router.Send:
			websocket.JSON.Send(message.Client.Socket, message.JSON)
		}
	}
}
