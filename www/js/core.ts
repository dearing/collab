declare var CodeMirror;

class userOptions {
    value: string;

    constructor (
        public nickname?        = "nobody",
        public theme?           = "twilight",
        public mode?            = "javascript",
        public lineNumbers?     = true,
        public indentSize?      = 4,
        public gutter?          = true,
        public lineWrapping?    = true,
        public indentWithTabs?  = true
        ) {}

    storageLoad() {
        console.log("loading from localstorage");
        for (var n in this) {
            if (n.search("storage") != 0) {
                if(localStorage[n] !== undefined) {
                    this[n] = localStorage[n];
                }
            }
        }    
    }

    storageSave() {
        console.log("saving to localstorage");
        for (var n in this) {
            if (n.search("storage") != 0){
             localStorage[n] = this[n];
            }
         }
    }
}

var user = new userOptions();
user.storageLoad();

var editor = CodeMirror.fromTextArea(document.getElementById("editor"), user);

var chatbox     = document.getElementById("chatbox");
var input       = document.getElementById("input");
var theme       = document.getElementById("theme");
var mode        = document.getElementById("mode");
var nickname    = document.getElementById("nickname");

input.onkeypress = chatSend;
nickname.onkeypress  = updateNick;

var server = "ws://" + window.location.host + "/collab";
var ws : WebSocket
var key = window.location.hash.substr(1,window.location.hash.length-1);

function websocketInit(e) {
    
    if (ws != undefined) ws.close();
    
    ws = new WebSocket(server)

    ws.onopen       = websocketOpen;
    ws.onclose      = websocketClose;
    ws.onerror      = websocketError;
    ws.onmessage    = websocketMessage;
}

function websocketError(e) {
    console.log("websocket connection error", e);
}

function websocketClose(e) {
    console.log("websocket connection closed");
}

function websocketMessage(e) {
    var x = JSON.parse(e.data);

    switch (x.Action) {

        case 'inform':
            chatbox.innerHTML = "<p class='inform'>" + x.Data + "</p>" + chatbox.innerHTML;
            notify('img/favicon.png',x.Origin,x.Data)
            break;

        case 'speech':
            chatbox.innerHTML = "<p class='speech'><span class='origin'>" + x.Origin + "</span> : " + x.Data + "</p>" + chatbox.innerHTML;
            notify('img/favicon.png',x.Origin,x.Data)
            break;

        case 'update-editor':
            c.off("change", handleEditorChange);
            updateEditor(x.Data);
            c.on("change", handleEditorChange);
            break;

        case 'update-editor-full':
            c.off("change", handleEditorChange);
            c.setValue(x.Data);
            c.on("change", handleEditorChange);
            break;

        case 'fetch-editor':
            ws.send(JSON.stringify({ Action: "update-editor-full", Data: c.getValue(), Origin: x.Origin }));
            break;
    }

}

function request_permission()
{
    // 0 means we have permission to display notifications
    if (window.webkitNotifications.checkPermission() == 0) {
        window.webkitNotifications.createNotification();
        } else {
        window.webkitNotifications.requestPermission();
    }
}


function notify(image, title, content)
{
    if (window.Notification) {
        var n = new Notification(title, {body: content, iconUrl: image });
        n.onshow   = function() { setTimeout(function() {n.close()}, 4000)};
    }
}

function websocketOpen(e) {
    console.log("websocket connection opened");
    ws.send(JSON.stringify({Action:"update-nick",Data: key, Origin: user.nickname }))
}


function chatSend(e) {
    if (e.keyCode == 13) {
        ws.send(JSON.stringify({Action:"speech",Data: input['value']}))
        input['value'] = "";
    }
}

function updateNick(e) {
    if (e.keyCode == 13 && nickname.value != user.nickname) {
        ws.send(JSON.stringify({Action:"update-nick", Data: nickname.value}))
        user.nickname = nickname.value;
        user.storageSave();
    }
}

function changeTheme() {
    editor.setOption("theme", theme.options[theme.selectedIndex].innerHTML);
    user.storageSave();
}

function changeMode() {
    editor.setOption("mode", mode.options[mode.selectedIndex].innerHTML);
    user.storageSave();
}

function generateKey() {
    var b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    var key = "DOC:";
      
    for ( var i = 0; i < 25; i++ )
        key += b.charAt(Math.floor(Math.random() * b.length-1));

      return key;
}

function handleEditorChange(o, u) {
    ws.send(JSON.stringify({Action: 'update-editor', Data: JSON.stringify(u)}));
}

function updateEditor(data) {
    var payload = JSON.parse(data);
    editor.replaceRange(payload.text.join("\n"), payload.from, payload.to);

    while('next' in payload) {
        payload = payload.next
        editor.replaceRange(payload.text.join("\n"), payload.from, payload.to);
    }
}


nickname.value      = user.nickname;
theme.value         = user.theme;
mode.value          = user.mode;

websocketInit(null);
editor.on("change", handleEditorChange);


