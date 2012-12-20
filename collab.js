//===================================================================
//  COLLAB.JS
//  provides a clean way to communicate with the websocket server
//===================================================================


Collab = {

    //ws: WebSocket,

    connect: function (host) {
        ws           = new WebSocket(host);
        ws.onopen    = Collab.wsopen;
        ws.onclose   = Collab.wsclose;
        ws.onerror   = Collab.wserror;
        ws.onmessage = Collab.wsmessage;
    },


    //===================================================================
    //  WEBSOCKETS
    //===================================================================
    wsopen: function () {
        console.log("connected");
        //Collab.changeNickname("jacob dearing");
        ws.send(JSON.stringify( { Action:"update-nickname", Data: Collab.createKey(), Origin: "jacob dearing" }))
    },

    wsclose: function () {
        console.log("disconnected")
    },

    wserror: function (e) {
        console.log(e)
    },

    wsmessage: function (e) {
        var x = JSON.parse(e.data);
        switch( x.Action )
        {
            case "inform":
                Collab.inform(x.Origin, x.Data);
                break;

            case "speech":
                Collab.speech(x.Origin, x.Data);
                break;
        }
    },

    //===================================================================
    //  MISC.
    //===================================================================
    compatible: function() {
        return window.WebSocket && window.localStorage;
    },

    createKey: function () {
        var key = "", b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for(var i = 0; i < 10; i++) key += b.charAt(Math.floor(Math.random() * b.length - 1));
        return key;
    },

    //===================================================================
    //  API
    //===================================================================
    sendMessage: function (message) {
        ws.send(JSON.stringify( { Action:"speech", Data: message }));
    },

    sendChanges: function (changeset) {
        ws.send(JSON.stringify( { Action:"update-editor", Data: changeset }))
    },

    changeNickname: function (nickname) {
        ws.send(JSON.stringify( { Action:"update-nickname", Data: nickname }))
    },

    inform: function () {},
    speech: function () {},

    //===================================================================
    //  LOCALSTORAGE
    //===================================================================
    load: function () {
        console.log("not implemented");
    },
    save: function () {
        console.log("not implemented");
    }
    
} // COLLAB.JS
