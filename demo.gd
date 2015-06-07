extends Node

const CONNECT_ATTEMPTS = 20

var InterpolationBuffer = load("interpolationbuffer.gd")

var buffers_initialized = false
var interpolation = false
var timer = 0
var host = true
var ready = false
var start = null
var connect = null
var window = null
var network_fps = null
var port = null
var ip = null

var packet_peer = PacketPeerUDP.new()

# For server
var clients = []

# For client
var seq = -1

# Boxes in the scene
var boxes = null

# Kinematic buffers for each of the boxes
var buffers = {}

func _ready():
	start = get_node("controls/start")
	connect = get_node("controls/connect")
	port = get_node("controls/port")
	ip = get_node("controls/ip")
	window = get_node("controls/window")
	network_fps = get_node("controls/network_fps")
	
	boxes = get_node("boxes").get_children()
	
	set_packet_peer_boxes(packet_peer)
	
	load_defaults()
	
	for box in boxes:
		buffers[box.get_name()] = InterpolationBuffer.new(window.get_value())
	
	buffers_initialized = true
	
	set_process(true)
	
	for arg in OS.get_cmdline_args():
		if (arg == "-server"):
			start_server()
			break

# Load default values
func load_defaults():
	var config_file = ConfigFile.new()
	config_file.load("res://defaults.cfg")
	ip.set_text(config_file.get_value("defaults", "ip"))
	port.set_value(config_file.get_value("defaults", "port"))
	window.set_value(config_file.get_value("defaults", "window"))
	network_fps.set_value(config_file.get_value("defaults", "network_fps"))

# Toggle starting/stoping a server
func _on_start_pressed():
	if (not ready):
		start_server()
	else:
		stop_server()	
	
# Toggle connecting/disconnecting a client
func _on_connect_pressed():
	if (not ready):
		start_client()
	else:
		stop_client();
		
func _process(delta):
	#Server update
	if (ready and host):
		# Handle incoming
		while (packet_peer.get_available_packet_count() > 0):
			var packet = packet_peer.get_var()
			
			if (packet == null):
				continue
			
			var ip = packet_peer.get_packet_ip()
			var port = packet_peer.get_packet_port()
			
			if (packet[0] == "connect"):
				if (not has_client(ip, port)):
					print("Client connected from ", ip, ":", port)
					clients.append({ ip = ip, port = port, seq = 0 })
				
				packet_peer.set_send_address(ip, port)
				packet_peer.put_var(["accepted"])
			elif (packet[0] == "event"):
				# Handle event locally
				handle_event(packet)
				
				# Broadcast event to clients
				for client in clients:
					if (client.ip != ip and client.port != port):
						packet_peer.set_send_address(ip, port)
						packet_peer.put_var(packet)
		
		# Send outgoing
		var duration = 1.0 / network_fps.get_value()
		
		if (timer < duration):
			timer += delta
		else:
			timer = 0
			for client in clients:
				var packet = ["update", client.seq]
				client.seq += 1
				for box in boxes:
					packet.append([box.get_name(), box.get_pos(), box.get_rot(), box.get_linear_velocity()])
				packet_peer.set_send_address(client.ip, client.port)
				packet_peer.put_var(packet)
	
	#Client update
	if (ready and not host):
		# Read snapshots from server and add it to a kinematic buffer (if interpolating),
		# or immediately update the local state (if not interpolating)
		
		while (packet_peer.get_available_packet_count() > 0):
			var packet = packet_peer.get_var()
			
			if (packet == null):
				continue
			
			if (packet[0] == "update"):
				if (packet[1] > seq):
					seq = packet[1]
					for i in range(2, packet.size()):
						var name = packet[i][0]
						var pos = packet[i][1]
						var rot = packet[i][2]
						var vel = packet[i][3]
						if (interpolation):
							buffers[name].push_state(pos, rot, vel)
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

# Change buffer window
func _on_window_value_changed(value):
	if (buffers_initialized):
		for box in boxes:
			buffers[box.get_name()].window = value
			buffers[box.get_name()].reset()

# Start/stop functions for client/server
func start_client():
	# Select a port for the client
	var client_port = port.get_val() + 1
	
	while (packet_peer.listen(client_port) != OK):
		client_port += 1
	
	# Set server address
	packet_peer.set_send_address(ip.get_text(), port.get_val())
	
	# Try to connect to server
	var attempts = 0
	var connected = false
	
	while (not connected and attempts < CONNECT_ATTEMPTS):
		attempts += 1
	
		packet_peer.put_var(["connect"])
		OS.delay_msec(50)
		
		while (packet_peer.get_available_packet_count() > 0):
			var packet = packet_peer.get_var()
			if (packet != null and packet[0] == "accepted"):
				connected = true
				break
	
	if (not connected):
		print("Error connecting to ", ip.get_text(), ":", port.get_val())
		return
	else:
		print("Connected to ", ip.get_text(), ":", port.get_val())
		connect.set_text("Disconnect")
		start.set_disabled(true)
		set_host_boxes(false)
		toggle_kinematic_boxes(true)
		host = false
		ready = true
	
func stop_client():
	ready = false
	host = true
	packet_peer.close()
	toggle_kinematic_boxes(false)
	set_host_boxes(true)
	print("Disconnected from ", ip.get_text(), ":", port.get_val())
	connect.set_text("Connect")
	start.set_disabled(false)
	
func start_server():
	if (packet_peer.listen(port.get_val()) != OK):
		print("Error listening on port ", port.get_value())
		return
	else:
		print("Listening on port ", port.get_value())
		start.set_text("Stop Server")
		connect.set_disabled(true)
		set_host_boxes(true)
		host = true
		ready = true
	
func stop_server():
	ready = false
	packet_peer.close()
	print("Stopped listening on ", port.get_value())
	start.set_text("Start Server")
	connect.set_disabled(false)

# Event handler
func handle_event(packet):
	var type = packet[1]
	var box = get_node("boxes/" + packet[2])
	
	if (type == "drag"):
		box.drag(packet[3])
	elif (type == "stop_drag"):
		box.stop_drag()

# Sets all boxes to host mode
func set_host_boxes(host):
	for box in boxes:
		box.host = host

# Set packet peer for boxes
func set_packet_peer_boxes(packet_peer):
	for box in boxes:
		box.packet_peer = packet_peer

# Sets toggles kinematic mode on boxes
func toggle_kinematic_boxes(enabled):
	for box in boxes:
		if (enabled):
			box.set_mode(RigidBody2D.MODE_KINEMATIC)
		else:
			box.set_mode(RigidBody2D.MODE_RIGID)
			box.set_sleeping(false)

# Check client is registered
func has_client(ip, port):
	for client in clients:
		if (client.ip == ip and client.port == port):
			return true
	return false
