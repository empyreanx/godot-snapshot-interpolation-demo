extends Node

var KinematicBuffer = load("kinematicbuffer.gd")

const FRAME_DURATION = 1.0 / 10.0
const BUFFER_WINDOW = 0.15

var interpolation = false
var timer = 0
var host = true
var ready = false
var start_btn = null
var connect_btn = null
var port = null
var ip = null

# For server
var server = TCP_Server.new()
var peers = []

# For client
var stream_peer = StreamPeerTCP.new()
var packet_peer = PacketPeerStream.new()

# Boxes in the scene
var boxes = null

# Kinematic buffers for each of the boxes
var buffers = {}

func _ready():
	start_btn = get_node("controls/start")
	connect_btn = get_node("controls/connect")
	port = get_node("controls/port")
	ip = get_node("controls/ip")
	boxes = get_node("boxes").get_children()
	
	for box in boxes:
		buffers[box.get_name()] = KinematicBuffer.new(BUFFER_WINDOW)
	
	packet_peer.set_stream_peer(stream_peer)
	set_process(true)
 
func load_defaults():
	pass
	

# Toggle starting/stoping a server
func _on_start_pressed():
	if (not ready):
		if (server.listen(port.get_val()) != OK):
			print("Error listening on port ", port.get_value())
		else:
			print("Listening on port ", port.get_value())
			start_btn.set_text("Stop Server")
			connect_btn.set_disabled(true)
			start_server()
	else:
		stop_server()
		print("Stopped listening on ", port.get_value())
		start_btn.set_text("Start Server")
		connect_btn.set_disabled(false)
		

# Toggle connecting/disconnecting a client
func _on_connect_pressed():
	if (not ready):
		if (stream_peer.connect(ip.get_text(), port.get_val()) != OK):
			print("Error connecting to ", ip.get_text(), ":", port.get_val())
		else:
			print("Connected to ", ip.get_text(), ":", port.get_val())
			connect_btn.set_text("Disconnect")
			start_btn.set_disabled(true)
			start_client()
			
	else:
		stop_client();
		print("Disconnected from ", ip.get_text(), ":", port.get_val())
		connect_btn.set_text("Connect")
		start_btn.set_disabled(false)
		
func _process(delta):
	#Server update
	if (ready and host):
		while (server.is_connection_available()):
			var stream_peer = server.take_connection()
			var packet_peer = PacketPeerStream.new()
			packet_peer.set_stream_peer(stream_peer)
			peers.append({ stream = stream_peer, packet = packet_peer })
		
		# After waiting (to simulate network less than ideal network conditions),
		# set a snapshot
		if (timer < FRAME_DURATION):
			timer += delta
		else:
			timer = 0
			for box in boxes:
				for peer in peers:
					if (peer.stream.is_connected()):
						peer.packet.put_var([box.get_name(), box.get_rot(), box.get_pos()])
		
		# Handle input
		for peer in peers:
			while (peer.packet.get_available_packet_count() > 0):
				var data = peer.packet.get_var()
				var type = data[0]
				var box = get_node("boxes/" + data[1])
				
				if (type == "drag"):
					box.drag(data[2])
				elif (type == "stop_drag"):
					box.stop_dragging()
	
	#Client update
	if (ready and not host and stream_peer.is_connected()):
		# Read snapshots from server and add it to a kinematic buffer (if interpolating),
		# or immediately update the local state (if not interpolating)
		while (packet_peer.get_available_packet_count() > 0):
			var data = packet_peer.get_var()
			var name = data[0]
			var rot = data[1]
			var pos = data[2]
			
			if (interpolation):
				buffers[name].push_frame(pos, rot)
			else:
				var box = get_node("boxes/" + name)
				box.set_pos(pos)
				box.set_rot(rot)
				
		# Update interpolation and local state
		if (interpolation):
			for box in boxes:
				var buffer = buffers[box.get_name()]
				buffer.update(delta)
				box.set_pos(buffer.get_pos())
				box.set_rot(buffer.get_rot())

# Toggle interpolation
func _on_lerp_toggled(pressed):
	interpolation = pressed
	
	if (pressed):
		for box in boxes:
			buffers[box.get_name()].reset()

# Start/stop functions for client/server
func start_client():
	set_host_boxes(false)
	toggle_kinematic_boxes(true)
	set_stream_boxes(packet_peer)
	host = false
	ready = true
	
func stop_client():
	ready = false
	host = true
	stream_peer.disconnect()
	toggle_kinematic_boxes(false)
	set_host_boxes(true)
	
func start_server():
	set_host_boxes(true)
	host = true
	ready = true
	
func stop_server():
	ready = false
	server.stop()

# Sets all boxes to host mode
func set_host_boxes(host):
	for box in boxes:
		box.host = host

# Set stream for boxes
func set_stream_boxes(stream):
	for box in boxes:
		box.stream = stream

# Sets toggles kinematic mode on boxes
func toggle_kinematic_boxes(enabled):
	for box in boxes:
		if (enabled):
			box.set_mode(RigidBody2D.MODE_KINEMATIC)
		else:
			box.set_mode(RigidBody2D.MODE_RIGID)
			box.set_sleeping(false)
