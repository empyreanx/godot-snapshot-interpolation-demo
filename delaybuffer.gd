const BUFFERING = 0
const PLAYING = 1

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
			rot = rot * alpha + buffer[0].rot * (1.0 - alpha)
			
		mark += delta
		
	time += delta
