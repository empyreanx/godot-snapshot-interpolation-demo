extends Node

var started = false
var connected = false

func _ready():
	pass

func _on_start_server_pressed():
	if (not started):
		started = true
		get_node("controls/connect").set_disabled(true)
		get_node("controls/start").set_text("Stop Server")
	else:
		started = false
		get_node("controls/connect").set_disabled(false)
		get_node("controls/start").set_text("Start Server")

func _on_connect_pressed():
	if (not connected):
		connected = true
		get_node("controls/start").set_disabled(true)
		get_node("controls/connect").set_text("Disconnect")
	else:
		connected = false
		get_node("controls/start").set_disabled(false)
		get_node("controls/connect").set_text("Connect")
