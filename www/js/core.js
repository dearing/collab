var collab_editor = (function () {
    function collab_editor(name, theme, mode, indentSize, gutter, lineWrapping, indentWithTabs) {
        if (typeof name === "undefined") { name = "unknown"; }
        if (typeof theme === "undefined") { theme = "cobalt"; }
        if (typeof mode === "undefined") { mode = "javascript"; }
        if (typeof indentSize === "undefined") { indentSize = 4; }
        if (typeof gutter === "undefined") { gutter = true; }
        if (typeof lineWrapping === "undefined") { lineWrapping = true; }
        if (typeof indentWithTabs === "undefined") { indentWithTabs = true; }
        this.name = name;
        this.theme = theme;
        this.mode = mode;
        this.indentSize = indentSize;
        this.gutter = gutter;
        this.lineWrapping = lineWrapping;
        this.indentWithTabs = indentWithTabs;
        this.name = name;
        this.theme = theme;
        this.mode = mode;
        this.indentSize = indentSize;
        this.gutter = gutter;
        this.lineWrapping = lineWrapping;
        this.indentWithTabs = indentWithTabs;
    }
    collab_editor.prototype.storageLoad = function () {
        console.log("loading from localstorage");
        for(var n in this) {
            if(n.search("storage") != 0) {
                this[n] = localStorage[n];
            }
        }
    };
    collab_editor.prototype.storageSave = function () {
        console.log("saveing to localstorage");
        for(var n in this) {
            if(n.search("storage") != 0) {
                localStorage[n] = this[n];
            }
        }
    };
    return collab_editor;
})();
var editor = new collab_editor();
editor.storageLoad();
var c = CodeMirror.fromTextArea(document.getElementById("editor"), editor);
var chatbox = document.getElementById("chatbox");
var inputbox = document.getElementById("inputbox");
var input = document.getElementById("input");
input.onkeypress = chatSend;
var server = "ws://" + window.location.host + "/collab";
var ws;
var key = window.location.hash;
document.title = key;
function websocketInit(e) {
    if(ws != undefined) {
        ws.close();
    }
    ws = new WebSocket(server);
    ws.onopen = websocketOpen;
    ws.onclose = websocketClose;
    ws.onerror = websocketError;
    ws.onmessage = websocketMessage;
}
function websocketError(e) {
    console.log("websocket connection error", e);
}
function websocketClose(e) {
    console.log("websocket connection closed");
}
function websocketMessage(e) {
    console.log("websocket connection message", e);
    var x = JSON.parse(e.data);
    console.log(x);
    switch(x.Action) {
        case 'inform': {
            chatbox.innerHTML += "<p class='inform'>" + x.Data + "</p>";
            break;

        }
        case 'speech': {
            chatbox.innerHTML += "<p class='speech'>" + x.Data + "<br /><span class='origin'>- " + x.Origin + "</span></p>";
            break;

        }
        case 'update-editor':
        case 'update-editor-full':
        case 'fetch-editor':
    }
}
function websocketOpen(e) {
    console.log("websocket connection opened");
    ws.send(JSON.stringify({
        Action: "update-nick",
        Data: key,
        Origin: editor.name
    }));
}
function chatSend(e) {
    if(e.keyCode == 13) {
        ws.send(JSON.stringify({
            Action: "speech",
            Data: input['value']
        }));
        input['value'] = "";
    }
}
websocketInit(null);
