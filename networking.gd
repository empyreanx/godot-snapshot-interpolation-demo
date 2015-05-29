extends Node

var host = true
var ready = false

var start_btn = null
var connect_btn = null
var port = null
var ip = null

var server = TCP_Server.new()
var peers = []

var stream_peer = StreamPeerTCP.new()
var packet_peer = PacketPeerStream.new()

var boxes = null

func _ready():
	start_btn = get_node("controls/start")
	connect_btn = get_node("controls/connect")
	port = get_node("controls/port")
	ip = get_node("controls/ip")
	boxes = get_node("boxes").get_children()	
	packet_peer.set_stream_peer(stream_peer)
	set_process(true)
 
func _on_start_pressed():
	if (not ready):
		host = true
		set_host_boxes(true)
		
		if (server.listen(port.get_val()) != OK):
			print("Error listening on port ", port.get_value())
		else:
			print("Listening on port ", port.get_value())
			ready = true
			connect_btn.set_disabled(true)
			start_btn.set_text("Stop Server")
	else:
		print("Stopped listening on ", port.get_value())
		ready = false
		connect_btn.set_disabled(false)
		start_btn.set_text("Start Server")
		server.stop()

func _on_connect_pressed():
	if (not ready):
		host = false
		set_host_boxes(false)
	
		if (stream_peer.connect(ip.get_text(), port.get_val()) != OK):
			print("Error connecting to ", ip.get_text(), ":", port.get_val())
		else:
			print("Connected to ", ip.get_text(), ":", port.get_val())
			ready = true
			start_btn.set_disabled(true)
			connect_btn.set_text("Disconnect")
			set_stream_boxes(packet_peer)
			toggle_kinematic_boxes(true)
			
	else:
		print("Disconnecting from ", ip.get_text(), ":", port.get_val())
		ready = false		
		start_btn.set_disabled(false)
		connect_btn.set_text("Connect")
		toggle_kinematic_boxes(false)
		stream_peer.disconnect()
		
func _process(delta):
	if (ready and host):
		while (server.is_connection_available()):
			var stream_peer = server.take_connection()
			var packet_peer = PacketPeerStream.new()
			packet_peer.set_stream_peer(stream_peer)
			peers.append({ stream = stream_peer, packet = packet_peer })
		
		for box in boxes:
			for peer in peers:
				if (peer.stream.is_connected()):
					peer.packet.put_var([box.get_name(), box.get_rot(), box.get_pos()])
		
		for peer in peers:
			while (peer.packet.get_available_packet_count() > 0):
				var data = peer.packet.get_var()
				var type = data[0]
				var box = get_node("boxes/" + data[1])
				
				if (type == "drag"):
					box.drag(data[2])
				elif (type == "stop_drag"):
					box.stop_dragging()
		
	if (ready and not host and stream_peer.is_connected()):
		while (packet_peer.get_available_packet_count() > 0):
			var data = packet_peer.get_var()
			var name = data[0]
			var rot = data[1]
			var pos = data[2]
			var box = get_node("boxes/" + name)
			box.set_pos(pos)
			box.set_rot(rot)

# sets all boxes to host mode
func set_host_boxes(host):
	for box in boxes:
		box.set_host(host)

# set stream for boxes
func set_stream_boxes(stream):
	for box in boxes:
		box.set_stream(stream)

# sets toggles kinematic mode on boxes
func toggle_kinematic_boxes(enabled):
	for box in boxes:
		if (enabled):
			box.set_mode(RigidBody2D.MODE_KINEMATIC)
		else:
			box.set_mode(RigidBody2D.MODE_RIGID)
			box.set_sleeping(false)
