extends RigidBody2D

const SCALE_FACTOR = 25

var dragging = false

func print_name():
	print(get_name())

func start_dragging():
	set_gravity_scale(0)
	set_linear_velocity(Vector2(0,0))
	dragging = true

func stop_dragging():
	dragging = false
	set_gravity_scale(1)
	set_applied_force(Vector2(0,0))

func _ready():
	set_process_input(true)
	pass

func _input_event(viewport, event, shape_idx):
	if (event.type == InputEvent.MOUSE_BUTTON and event.pressed):
		start_dragging()

func _input(event):
		var rect = get_tree().get_root().get_rect()
		var pos = event.pos
		
		if (event.type == InputEvent.MOUSE_MOTION and dragging):
			if (pos.x <= 0 or pos.y <= 0 or pos.x >= (rect.size.x - 1) or pos.y >= (rect.size.y - 1)):
				stop_dragging()
			else:
				set_applied_force((pos - get_pos()) * SCALE_FACTOR)
				
		elif (event.type == InputEvent.MOUSE_BUTTON and not event.pressed and dragging):
			stop_dragging()
	