package main

// JSON format of a client intent, payload and origin

import (
	"code.google.com/p/go.net/websocket"
	. "fmt"
)

type Client struct {
	Name   string
	Socket *websocket.Conn
	Lock   bool
}

type ClientJSON struct {
	Action string // an intent
	Data   string // payload of intent
	Origin string // origin of intent
}


func (client *Client) mesg(action, data, origin string) *Message {
	return &Message{Client: client, JSON: &ClientJSON{Action: action, Data: data, Origin: origin}}
}

func echo(action, data, origin string) *ClientJSON {
	return &ClientJSON{Action: action, Data: data, Origin: origin}
}



func (client *Client) Loop() {

	var q ClientJSON

	defer func() {
		Router.Remove <- client
		Router.Broadcast <- client.mesg("inform", Sprintf("%s disconnected.", client.Name), "Server")
	}()

	if err := websocket.JSON.Receive(client.Socket, &q); err != nil {
		return
	}

	client.Name = q.Data
	Router.Echo <- echo("inform", Sprintf("%s connected.", client.Name), "Server")

	// gnab the first copy of the text we can find (that is not our own)
	for peer := range Router.Clients {
		if client != peer {
			websocket.JSON.Send(peer.Socket, &ClientJSON{Action: "fetch-editor", Origin: client.Name})
			break
		}
	}

	for {

		var q ClientJSON
		if err := websocket.JSON.Receive(client.Socket, &q); err != nil {
			break
		}

		//println(Sprintf("%s: %s => %s", client.Name, q.Action, q.Data))

		// what to do...
		switch q.Action {

		case "disconnect":
			return

		case "speech":
			Router.Echo <- echo("speech",q.Data,client.Name)
		case "lock":
			client.Lock = true
			Router.Broadcast <- client.mesg("lock", q.Data, client.Name)

		case "unlock":
			client.Lock = false
			Router.Broadcast <- client.mesg("lock", q.Data, client.Name)

		case "update-nick":
			client.Name, q.Data = q.Data, client.Name // yea, that just happened
			Router.Broadcast <- client.mesg("inform", Sprintf("%s changed nickname to %s", q.Data, client.Name), client.Name)

		case "update-editor", "fetch-editor", "update-editor-full":
			Router.Broadcast <- client.mesg(q.Action, q.Data, client.Name)
		}
	}
}
