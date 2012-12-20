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
        Collab.send("nickname","TESTING-KEY","nobody")
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

            case "message":
                Collab.onmessage(x.Origin, x.Data);
                break;

            case "update":
                Collab.onupdate(x.Origin, x.Data);
                break;

            case "request":
                Collab.onrequest();
        }
    },


    //===================================================================
    //  MISC.
    //===================================================================

    compatible: function() {
        return window.WebSocket;
    },

    createKey: function () {
        var key = "", b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for(var i = 0; i < 10; i++) key += b.charAt(Math.floor(Math.random() * b.length - 1));
        return key;
    },

    //===================================================================
    //  API
    //===================================================================

    send: function (action, data, origin) {
        ws.send(JSON.stringify( { Action: action, Data: data, Origin: origin}));
    },

    oninform:   function () {console.log("`oninform` not implemented")},
    onmessage:  function () {console.log("`onmessage` not implemented")},
    onchange:   function () {console.log("`onchange` not implemented")},
    onrequest:  function () {console.log("`onrequest` not implemented")},
    onupdate:   function () {console.log("`update` not implemented")},

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
