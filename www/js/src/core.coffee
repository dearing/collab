banner = """
/*.uef^"        :8                        x .d88"    cuuu....uK    
:d88E          .88       ..    .     :     5888R     888888888     
`888E         :888ooo  .888: x888  x888.   '888R     8*888**"      
 888E .z8k  -*8888888 ~`8888~'888X`?888f`   888R     >  .....      
 888E~?888L   8888      X888  888X '888>    888R     Lz"  ^888Nu   
 888E  888E   8888      X888  888X '888>    888R     F     '8888k  
 888E  888E   8888      X888  888X '888>    888R     ..     88888> 
 888E  888E  .8888Lu=   X888  888X '888>    888R    @888L   88888  
 888E  888E  ^%888*    "*88%""*88" '888!`  .888B . '8888F   8888F  
m888N= 888>    'Y"       `~    "    `"`    ^*888%   %8F"   d888"   
 `Y"   888                                   "%      ^"===*%"`     
      J88"                                                         
      @%                                                           
    :"
*/                                                           
"""

if !WebSocket?
	alert "client does not support websockets"
if !localStorage?
	alert "client does not support local storage"

ws 		= null
count 	= 1
store 	= localStorage
server 	= "ws://#{window.location.host}/api"

copen 	= new Audio "snd/c-open.ogg"
cclose 	= new Audio "snd/c-close.ogg"
ccall 	= new Audio "snd/c-call.ogg"


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

user.name  	= prompt "no username in storage, please enter one now","spanky, destroyer of worlds" if !user.name?
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
			when "fetch-editor" 
				ws.send JSON.stringify {Action:"update-editor-full", Data: codeEditor.getValue(), Origin: x.Origin}
			when "update-editor-full" 
				codeEditor.setOption 'onChange', null
				codeEditor.setValue x.Data
				codeEditor.setOption 'onChange', handleEditorChange

`function updateEditor(data) {
	var x = JSON.parse(data);
	codeEditor.replaceRange(x.text.join("\n"), x.from, x.to);
	while(x.next === 'defined') {
		UpdateEditor(x.next);
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
	theme			: user.theme, 
	mode			: user.mode, 
	gutter			: user.gutter, 
	lineNumbers		: user.lineNumbers,
	smartIndent 	: false,
	tabSize			: user.tabSize,
	indentWithTabs 	: user.indentWithTabs,
	lineWrapping	: user.lineWrapping,
	value			: banner
}

handleEditorChange = (o,u) ->
	ws.send JSON.stringify({Action: 'update-editor', Data: JSON.stringify u })

wsconnect()

codeEditor.setOption 'onChange', handleEditorChange
	