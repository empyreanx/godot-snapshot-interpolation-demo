extends RigidBody2D

const EVENT_START_DRAG = 0
const EVENT_END_DRAG = 1
const EVENT_DRAGGING = 2

const SCALE_FACTOR = 25

var dragging = false
var host = true;
var packet_peer = null

func _ready():
	set_process_input(true)

func _input_event(viewport, event, shape_idx):
	if (event.type == InputEvent.MOUSE_BUTTON and event.pressed):
		start_drag()

func _input(event):
		if (event.type == InputEvent.MOUSE_MOTION and dragging):
			var rect = get_tree().get_root().get_rect()
			var pos = event.pos
			
			if (pos.x <= 0 or pos.y <= 0 or pos.x >= (rect.size.x - 1) or pos.y >= (rect.size.y - 1)):
				stop_drag()
			else:
				drag(pos)
				
		elif (event.type == InputEvent.MOUSE_BUTTON and not event.pressed and dragging):
			stop_drag()

func start_drag():
	dragging = true

	if (host):
		set_gravity_scale(0)
		set_linear_velocity(Vector2(0,0))
		

func stop_drag():
	dragging = false
	
	if (host):
		set_gravity_scale(1)
		set_applied_force(Vector2(0,0))
	else:
		packet_peer.put_var(["event", "stop_drag", get_name()])

func drag(pos):
	if (host):
		set_applied_force((pos - get_pos()) * SCALE_FACTOR)
	else:
		packet_peer.put_var(["event", "drag", get_name(), pos])