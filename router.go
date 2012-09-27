package main

import (
	"code.google.com/p/go.net/websocket"
)

type router struct {
	Add       chan *Client
	Remove    chan *Client
	Echo      chan *ClientJSON
	Broadcast chan *Message
	Send      chan *Message
	Clients   map[*Client]bool
}

var Router = router{
	Add:       make(chan *Client),
	Remove:    make(chan *Client),
	Echo:      make(chan *ClientJSON),
	Broadcast: make(chan *Message),
	Send:      make(chan *Message),
	Clients:   make(map[*Client]bool),
}

type Message struct {
	Client *Client
	JSON   *ClientJSON
}

// await work on a channel
func (Router *router) HandleClients() {
	for {
		select {

		// ADD *client
		case client := <-Router.Add:
			Router.Clients[client] = true

		// REMOVE *client
		case client := <-Router.Remove:
			client.Socket.Close()
			delete(Router.Clients, client)

		// ECHO
		case Data := <-Router.Echo:
			for client := range Router.Clients {
				websocket.JSON.Send(client.Socket, Data)
			}

		// BROADCAST (!SEND)
		case message := <-Router.Broadcast:
			for client := range Router.Clients {
				if client != message.Client {
					websocket.JSON.Send(message.Client.Socket, message.JSON)
				}
			}

		// SEND (!BROADCAST)
		case message := <-Router.Send:
			websocket.JSON.Send(message.Client.Socket, message.JSON)
		}
	}
}
