var delay = 0
var buffer = []
var state = { pos = Vector2(0,0), rot = 0.0, age = 0.0 }

func _init(buffer_delay):
	delay = buffer_delay

func push_frame(pos, rot):
	buffer.push_back({ pos = pos, rot = rot, age = 0.0 })

func get_pos():
	return state.pos

func get_rot():
	return state.rot

func update(delta):
	while (buffer.size() >= 2 and buffer[1].age > delay):
		buffer.remove(0)

	if (buffer.size() >= 2 and buffer[0].age > delay):
		state.pos = lerp_pos(buffer[0], buffer[1])
		state.rot = lerp_rot(buffer[0], buffer[1])
		state.age = delay
	elif (buffer.size() > 0 and buffer[0].age < delay):
		state.pos = lerp_pos(state, buffer[0])
		state.rot = lerp_rot(state, buffer[0])
		state.age = delay
	elif (buffer.size() > 0):
		state = buffer[0]
		state.age += delta
	else:
		state.age += delta
	
	for frame in buffer:
		frame.age += delta

func lerp_pos(s1, s2):
	var alpha = (s1.age - delay) / (s1.age - s2.age)
	return s1.pos * alpha + s2.pos * (1.0 - alpha)
	
func lerp_rot(s1, s2):
	var alpha = (s1.age - delay) / (s1.age - s2.age)
	return s1.rot * alpha + s2.rot * (1.0 - alpha)