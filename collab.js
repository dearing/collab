//===================================================================
//  COLLAB.JS
//  provides a clean way to communicate with the websocket server
//===================================================================

Collab = {

    connect: function (host) {
        ws           = new WebSocket(host);
        ws.onopen    = Collab.wsopen;
        ws.onclose   = Collab.wsclose;
        ws.onerror   = Collab.wserror;
        ws.onmessage = Collab.wsmessage;
    },


    //===================================================================
    //  WEBSOCKET
    //===================================================================
    wsopen: function () {
        console.log("connected");
        ws.send(JSON.stringify( { Action:"update-nickname", Data: "testing", Origin: "jacob dearing" }))
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
                Collab.oninform(x.Data);
                break;

            case "speech":
                Collab.onspeech(x.Origin, x.Data);
                break;

            case "update-editor":
                Collab.ondata(x.Origin, x.Data);
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

    sendData: function (data) {
        ws.send(JSON.stringify( {Action:"update-editor", Data: data}));
    },

    changeNickname: function (nickname) {
        ws.send(JSON.stringify( { Action:"update-nick", Data: nickname }))
    },

    oninform: function () {console.log("`oninform` not implemented")},
    onspeech: function () {console.log("`onspeech` not implemented")},
    ondata:   function () {console.log("`ondata` not implemented")},

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
