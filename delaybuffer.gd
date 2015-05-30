const BUFFERING = 0
const PLAYING = 1

const EPSILON = 0.0005

var state = BUFFERING
var buffer = []
var window = 0
var time = 0
var mark = 0
var pos = Vector2(0,0)
var rot = 0
var last_time = 0.0

func _init(window):
	self.window = window
	
func reset():
	state = BUFFERING
	buffer = []
	time = 0
	mark = 0
	pos = Vector2(0,0)
	rot = 0
	last_time = 0

func push_frame(pos, rot):
	buffer.push_back({ pos = pos, rot = rot, time = time })

func get_pos():
	return pos

func get_rot():
	return rot

func update(delta):
	if (state == BUFFERING):
		if (buffer.size() > 0):
			pos = buffer[0].pos
			rot = buffer[0].rot
			last_time = buffer[0].time
			
			if (time > window):
				state = PLAYING
	elif (state == PLAYING):
		while (buffer.size() > 0 and mark > buffer[0].time):
			pos = buffer[0].pos
			rot = buffer[0].rot
			last_time = buffer[0].time
			buffer.remove(0)
		
		if (buffer.size() > 0):
			var alpha = (buffer[0].time - mark) / (buffer[0].time - last_time)
			pos = pos * alpha + buffer[0].pos * (1.0 - alpha)
			rot = slerp_rot(rot, buffer[0].rot, 1.0 - alpha)
			#rot = rot * alpha + buffer[0].rot * (1.0 - alpha)
			
		mark += delta
		
	time += delta

func slerp_rot(r1, r2, alpha):
	var v1 = Vector2(cos(r1), sin(r1))
	var v2 = Vector2(cos(r2), sin(r2))
	var v = slerp(v1, v2, alpha)
	return atan2(v.y, v.x)

func slerp(v1, v2, alpha):
	var cos_angle = v1.dot(v2)
	var angle = acos(cos_angle)
	var angle_alpha = angle * alpha
	var v3 = (v2 - (v1.dot(v2) * v1)).normalized()
	return v1 * cos(angle_alpha) + v3 * sin(angle_alpha)