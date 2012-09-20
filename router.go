package main

import (
	"code.google.com/p/go.net/websocket"
	. "fmt"
)

type hub struct {
	register   chan *ConsoleClient
	unregister chan *ConsoleClient
	broadcast  chan *ConsoleJSON
	clients    map[*ConsoleClient]bool
}

type ConsoleJSON struct {
	Action string
	Data   string
	Origin string
}

type ConsoleClient struct {
	Name   string
	Socket *websocket.Conn
	UID    int
	Send   chan *ConsoleJSON
	Lock   bool
}

type router struct {
	Register       chan *ConsoleClient
	Unregister     chan *ConsoleClient
	Broadcast      chan *ConsoleJSON
	ConsoleClients map[*ConsoleClient]bool
}

var R = router{
	Register:       make(chan *ConsoleClient),
	Unregister:     make(chan *ConsoleClient),
	Broadcast:      make(chan *ConsoleJSON),
	ConsoleClients: make(map[*ConsoleClient]bool),
}

var lastchange = ""

func (client *ConsoleClient) loop() {
	for {
		var q ConsoleJSON
		if err := websocket.JSON.Receive(client.Socket, &q); err != nil {
			break
		}

		//println(Sprintf("%s: %s => %s", client.Name, q.Action, q.Data))

		switch q.Action {
		case "speech":
			R.Broadcast <- &ConsoleJSON{Action: "speech", Data: q.Data, Origin: client.Name}
		case "lock":
			client.Lock = true
			for peer := range R.ConsoleClients {
				if client != peer {
					peer.Lock = false
					websocket.JSON.Send(peer.Socket, &ConsoleJSON{Action: "lock", Origin: client.Name})
				}
			}
			break
		case "disconnect":
			return
		case "update-nick":
			var old = client.Name
			client.Name = q.Data
			R.Broadcast <- &ConsoleJSON{Action: "inform", Data: Sprintf("%s changed nickname to %s", old, client.Name), Origin: client.Name}
		case "update-editor", "fetch-editor", "update-editor-full":
			if q.Data == lastchange {
				break
			}
			lastchange = q.Data
			for peer := range R.ConsoleClients {
				if client != peer {
					websocket.JSON.Send(peer.Socket, &ConsoleJSON{Action: q.Action, Data: q.Data, Origin: client.Name})
				}
			}
		}

		select {
		case v := <-client.Send:
			if err := websocket.JSON.Send(client.Socket, v); err != nil {
				break
			}
		default:
		}
	}
}

var count = 0

func WebsocketHandler(ws *websocket.Conn) {

	count++
	client := &ConsoleClient{
		Name:   "Client",
		Socket: ws,
		UID:    count, 
		Send:   make(chan *ConsoleJSON, 256),
	}

	var q ConsoleJSON

	if err := websocket.JSON.Receive(client.Socket, &q); err != nil {
		return
	}

	client.Name = q.Data

	R.Register <- client
	R.Broadcast <- &ConsoleJSON{Action: "inform", Data: Sprintf("%s connected.", client.Name), Origin: "Server"}

	for peer := range R.ConsoleClients {
		if client != peer {
			websocket.JSON.Send(peer.Socket, &ConsoleJSON{Action: "fetch-editor", Origin: client.Name})
			break
		}
	}

	// loops for reads and writes
	client.loop()

	// end of client life
	R.Unregister <- client
	R.Broadcast <- &ConsoleJSON{Action: "inform", Data: Sprintf("%s disconnected.", client.Name), Origin: "Server"}
}

func (R *router) HandleClients() {
	println("handling websocket clients...")
	for {
		// await something from a channel
		select {
		case client := <-R.Register:
			Printf("[%s]->register\n", client.Name)
			R.ConsoleClients[client] = true

		case client := <-R.Unregister:
			Printf("[%s]->unregister\n", client.Name)
			client.Socket.Close()
			delete(R.ConsoleClients, client)
			close(client.Send)

		case Data := <-R.Broadcast:
			for client := range R.ConsoleClients {
				websocket.JSON.Send(client.Socket, Data)
			}
		}
	}
}
