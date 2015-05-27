extends RigidBody2D

const SCALE_FACTOR = 50

var dragging = false

func _ready():
	set_process_input(true)
	pass

func _input_event(viewport, event, shape_idx):
	if (event.type == InputEvent.MOUSE_BUTTON and event.pressed):
		set_gravity_scale(0)
		set_linear_velocity(Vector2(0,0))
		dragging = true

func _input(event):
		if (event.type == InputEvent.MOUSE_MOTION and dragging):
			set_applied_force((event.pos - get_pos()) * SCALE_FACTOR)
		elif (event.type == InputEvent.MOUSE_BUTTON and not event.pressed and dragging):
			dragging = false
			set_gravity_scale(1)
			set_applied_force(Vector2(0,0))
	