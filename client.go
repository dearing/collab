package main

import (
	"code.google.com/p/go.net/websocket"
	. "fmt"
)

// Websocket client
type Client struct {
	ID     string          // generated unique id
	Name   string          // a nickname
	Lock   bool            // a lock to prevent the client from editing the active document
	Socket *websocket.Conn // websocket for this client
	Key    string          // id of document
}

// JSON format of a client intent, payload and origin
type ClientJSON struct {
	Action string // an intent
	Data   string // payload of intent
	Origin string // origin of intent
}

// One can just us &Message directly but I find it all messy when stacked as I do later.
// More so in this case as it is nested.
func (client *Client) mesg(action, data, origin string) *Message {
	return &Message{Client: client, JSON: &ClientJSON{Action: action, Data: data, Origin: origin}}
}

// At this point we have a goroutine handling this client who requested this websocket
// The client is considered connected for the remainder of this routine, since this is
// on a goroutine we do not need to fret about blocking.
func WebsocketHandler(ws *websocket.Conn) {

	client := &Client{ID: <-Router.GetID, Socket: ws}

	// we need a document key before we add this client
	var q ClientJSON
	if err := websocket.JSON.Receive(client.Socket, &q); err != nil {
		return
	}

	//client.Name = q.Origin
	client.Name = q.Origin
	client.Key = q.Data

	Router.Add <- client

	defer func() {
		Router.Remove <- client
		Router.Echo <- client.mesg("inform", Sprintf("user %s disconnected.", client.Name), "Server")
	}()

	Router.Echo <- client.mesg("inform", Sprintf("user %s connected.", client.Name), "Server")

	// Request a clean copy of the 'active' document for on behalf of this client.
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

		println(Sprintf("%s: `%s` %s => %s", client.Name, client.Key, q.Action, q.Data))

		// JSON comes in from a client
		// We peek at the Action which is an intent from the client
		// and handle it accordingly

		switch q.Action {

		case "disconnect":
			return

		case "speech":
			Router.Echo <- client.mesg("speech", q.Data, client.Name)

		case "lock":
			client.Lock = true
			Router.Broadcast <- client.mesg("lock", q.Data, client.Name)

		case "unlock":
			client.Lock = false
			Router.Broadcast <- client.mesg("unlock", q.Data, client.Name)

		case "update-nick":
			client.Name, q.Data = q.Data, client.Name // yea, that just happened
			Router.Echo <- client.mesg("inform", Sprintf("%s changed nickname to %s", q.Data, client.Name), client.Name)

		case "update-editor", "fetch-editor", "update-editor-full":
			Router.Broadcast <- client.mesg(q.Action, q.Data, client.Name)
		}
	}
}
