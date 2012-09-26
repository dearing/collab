if !WebSocket?
	alert "client does not support websockets"
if !localStorage?
	alert "client does not support local storage"

ws 		= null
count 	= 1
store 	= localStorage
server 	= "wss://#{window.location.host}/collab"

copen 	= new Audio "snd/c-open.ogg"
cclose 	= new Audio "snd/c-close.ogg"
ccall 	= new Audio "snd/c-call.ogg"

lastChange = ""

class LiveEditUser
	save: ->
		store["userName"] 		= this.name
		store["theme"] 			= this.theme
		store["mode"] 			= this.mode
		store["lineNumbers"]	= this.lineNumbers
		store["gutter"]			= this.gutter
		store["tabSize"]		= this.tabSize
		store["indentWithTabs"] = this.indentWithTabs
		store["lineWrapping"] 	= this.lineWrapping

	load: ->
		this.name  			= store["userName"]
		this.mode  			= store["mode"]
		this.theme 			= store["theme"]
		this.lineNumbers  	= store["lineNumbers"]
		this.gutter 		= store["gutter"]	
		this.tabSize		= store["tabSize"]
		this.indentWithTabs = store["indentWithTabs"]
		this.lineWrapping   = store["lineWrapping"]

user = new LiveEditUser 

user.load()

$('#settings').modal(show: true) if !user.name?

user.name  	= prompt "no username in storage, please enter one now","nobody" if !user.name?
user.mode 	= "javascript" 	if !user.mode?
user.theme 	= "cobalt" 		if !user.theme?
user.save()

$('#profile-name').html "<i class='icon-user'></i> #{user.name} <span class='caret'></span></a>"

wsconnect = ->
	ws.close() if ws?
	ws = new WebSocket server
	ws.onopen = ->
		ws.send JSON.stringify {Action:"update-nick",Data: user.name}
		copen.play()
	ws.onclose = ->
		cclose.play()
	ws.onerror = ->
		console.log "socket error"
	ws.onmessage = (e) ->
		x = JSON.parse(e.data)
		switch x.Action	
			when "inform" 
				$('#chat').html "#{$('#chat').html()}<p><span class='label label-info'> #{x.Data}</span></p>"
				ccall.play()
			when "speech"
				d = new Date();
				$('#chat').html "#{$('#chat').html()}<blockquote><p>#{x.Data}</p><small>#{x.Origin} - #{d.getHours()}:#{d.getMinutes()}:#{d.getSeconds()}</small></blockquote>" 
				$('#chat').scrollTop 999999999
				copen.play()
			when "update-editor" 
				codeEditor.setOption 'onChange', null
				updateEditor x.Data
				codeEditor.setOption 'onChange', handleEditorChange
				lastChange = x.Data
			when "fetch-editor" 
				ws.send JSON.stringify {Action:"update-editor-full", Data: codeEditor.getValue(), Origin: x.Origin}
			when "update-editor-full" 
				codeEditor.setOption 'onChange', null
				codeEditor.setValue x.Data
				codeEditor.setOption 'onChange', handleEditorChange

`function updateEditor(data) {
	var payload = JSON.parse(data);
	codeEditor.replaceRange(payload.text.join("\n"), payload.from, payload.to);

	while('next' in payload) {
		payload = payload.next
		codeEditor.replaceRange(payload.text.join("\n"), payload.from, payload.to);
	}
}`
wsdisconnect = ->
	return if ws
	ws.close()
	ws = null

wsreconnect = ->
	wsdisconnect()
	wsconnect()

$('#ux-connect').click 		-> wsconnect()
$('#ux-disconnect').click 	-> wsdisconnect()
$('#ux-reconnect').click 	-> wsreconnect()

chatsend = ->
	input = $("#chat-message")
	if input.val() == "" then return
	ws.send JSON.stringify({Action:"speech",Data: input.val()})
	input.focus()
	input.select()
	#input.val("")

$('#chat-send').click -> chatsend()
$('#chat-message').keypress (e) -> 
	chatsend() if e.keyCode == 13

$('#ux-chat-clear').click -> 
	$('#chat').html ""

$('#ux-editor-clear').click -> 
	codeEditor.setValue ""

$('#ux-editor-sync').click -> 
	ws.send JSON.stringify {Action: "fetch-editor"}

$('#settings-save').click ->
	store.clear()
	if user.name != $('#settings-username').val()
		ws.send JSON.stringify {Action:"update-nick", Data: $('#settings-username').val()}
	user.name 			= $('#settings-username').val()
	user.theme 			= $('#settings-theme').val()
	user.mode 			= $('#settings-mode').val()
	user.tabSize		= $('#settings-tabSize').val()
	user.lineWrapping 	= $('#settings-lineWrapping').is(':checked')
	user.gutter 		= $('#settings-gutter').is(':checked')
	user.lineNumbers 	= $('#settings-lineNumbers').is(':checked')
	user.indentWithTabs = $('#settings-indentWithTabs').is(':checked')
	$('#profile-name').html "<i class='icon-user'></i> #{user.name} <span class='caret'></span></a>"
	codeEditor.setOption("mode",user.mode)
	codeEditor.setOption("theme",user.theme)
	codeEditor.setOption("lineWrapping",user.lineWrapping)
	codeEditor.setOption("tabSize",user.tabSize)
	codeEditor.setOption("gutter",user.gutter)
	codeEditor.setOption("lineNumbers",user.lineNumbers)
	codeEditor.setOption("indentWithTabs",user.indentWithTabs)
	codeEditor.refresh()
	user.save()

prepareSettingsModal = ->
	$('#settings-username').val(user.name)
	$('#settings-theme').val(user.theme)
	$('#settings-mode').val(user.mode)
	$('#settings-tabSize').val(user.tabSize)
	$('#settings-lineWrapping').prop("checked", user.lineWrapping)
	$('#settings-gutter').prop("checked", user.gutter)
	$('#settings-lineNumbers').prop("checked", user.lineNumbers)
	$('#settings-indentWithTabs').prop("checked", user.indentWithTabs)

prepareSettingsModal()

codeEditor = CodeMirror editor, 
{
	indentWithTabs 	: true,
	theme			: user.theme, 
	mode			: user.mode, 
	gutter			: user.gutter, 
	lineNumbers		: user.lineNumbers,
	#smartIndent 	: false,
	tabSize			: user.tabSize,
	indentWithTabs 	: user.indentWithTabs,
	lineWrapping	: user.lineWrapping,
	value			: "//blank document"
}

handleEditorChange = (o,u) ->
	ws.send JSON.stringify({Action: 'update-editor', Data: JSON.stringify u }) if lastChange != u

wsconnect()

codeEditor.setOption 'onChange', handleEditorChange
