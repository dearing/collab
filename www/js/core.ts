declare var CodeMirror;

class collab_editor {
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

var editor = new collab_editor();
editor.storageLoad();
console.log(editor)

console.log()

var c = CodeMirror.fromTextArea(document.getElementById("editor"), editor);

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
            break;

        case 'speech':
            chatbox.innerHTML = "<p class='speech'><span class='origin'>" + x.Origin + "</span> : " + x.Data + "</p>" + chatbox.innerHTML;
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

function websocketOpen(e) {
    console.log("websocket connection opened");
    ws.send(JSON.stringify({Action:"update-nick",Data: key, Origin: editor.nickname }))
}


function chatSend(e) {
    if (e.keyCode == 13) {
        ws.send(JSON.stringify({Action:"speech",Data: input['value']}))
        input['value'] = "";
    }
}

function updateNick(e) {
    if (e.keyCode == 13) {
        ws.send(JSON.stringify({Action:"update-nick", Data: nickname.value}))
        editor.nickname = nickname.value;
        editor.storageSave();
    }
}

function changeTheme() {
    c.setOption("theme", theme.options[theme.selectedIndex].innerHTML);
    editor.storageSave();
}

function changeMode() {
    c.setOption("mode", mode.options[mode.selectedIndex].innerHTML);
    editor.storageSave();
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
    c.replaceRange(payload.text.join("\n"), payload.from, payload.to);

    while('next' in payload) {
        payload = payload.next
        c.replaceRange(payload.text.join("\n"), payload.from, payload.to);
    }
}


nickname.value      = editor.nickname;
theme.value         = editor.theme;
mode.value          = editor.mode;

websocketInit(null);
c.on("change", handleEditorChange);

