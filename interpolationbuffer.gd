const BUFFERING = 0
const PLAYING = 1

var initialized = false
var state = BUFFERING
var buffer = []
var window = 0
var time = 0
var mark = 0
var last_pos = Vector2(0,0)
var last_vel = Vector2(0,0)
var last_rot = 0
var last_time = 0.0
var pos = Vector2(0,0)
var rot = 0

# Window - time length of buffer
func _init(window):
	self.window = window

# Called on connect
func reset():
	initialized = false
	state = BUFFERING
	buffer = []
	time = 0
	mark = 0
	last_pos = Vector2(0,0)
	last_vel = Vector2(0,0)
	last_rot = 0
	last_time = 0
	pos = Vector2(0,0)
	rot = 0
	
func push_frame(pos, rot, vel):
	buffer.push_back({ pos = pos, rot = rot, vel = vel, time = time })

func get_pos():
	return pos

func get_rot():
	return rot

# Perform interpolation for frame
func update(delta):
	if (state == BUFFERING):
		if (buffer.size() > 0 and not initialized):
			last_pos = buffer[0].pos
			last_rot = buffer[0].rot
			last_vel = buffer[0].vel
			last_time = buffer[0].time
			initialized = true
			buffer.erase(0)
			
		if (buffer.size() > 0 and initialized and time > window):
			state = PLAYING
	elif (state == PLAYING):
		# Purge buffer of expired frames
		while (buffer.size() > 0 and mark > buffer[0].time):
			last_pos = buffer[0].pos
			last_rot = buffer[0].rot
			last_vel = buffer[0].vel
			last_time = buffer[0].time
			buffer.remove(0)
		
		if (buffer.size() > 0 and buffer[0].time > 0):
			var delta_time = buffer[0].time - last_time
			var alpha = (mark - last_time) / (delta_time)
			
			# Use cubic Hermite interpolation to determine position
			pos = hermite(alpha, last_pos, buffer[0].pos, last_vel * delta_time, buffer[0].vel * delta_time)
			
			# Linear interpolation of position
			#pos = lerp_vector(last_pos, buffer[0].pos, 1.0 - alpha)
			
			# Spherical interpolation of rotation
			rot = slerp_rot(last_rot, buffer[0].rot, alpha)
			
			# Naive (wrong) method of interpolating rotations:
			#rot = rot * alpha + buffer[0].rot * (1.0 - alpha)
			
		mark += delta
		
	time += delta

# Lerp vector
func lerp_vector(v1, v2, alpha):
	return v1 * alpha + v2 * (1.0 - alpha)

# Cubic Hermite interpolation
func hermite(t, p1, p2, v1, v2):
	var t2 = pow(t, 2)
	var t3 = pow(t, 3)
	var a = 1 - 3*t2 + 2*t3
	var b = t2 * (3 - 2*t)
	var c = t * pow(t - 1, 2)
	var d = t2 * (t - 1)
	return a * p1 + b * p2 + c * v1 + d * v2

# Spherically linear interpolation of rotation
func slerp_rot(r1, r2, alpha):
	var v1 = Vector2(cos(r1), sin(r1))
	var v2 = Vector2(cos(r2), sin(r2))
	var v = slerp(v1, v2, alpha)
	return atan2(v.y, v.x)

# Spherical linear interpolation of two 2D vectors
func slerp(v1, v2, alpha):
	var cos_angle = v1.dot(v2)
	var angle = acos(cos_angle)
	var angle_alpha = angle * alpha
	var v3 = (v2 - (v1.dot(v2) * v1)).normalized()
	return v1 * cos(angle_alpha) + v3 * sin(angle_alpha)
