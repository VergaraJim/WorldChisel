extends Camera2D

var mouse_start_pos
var camera_start_position

var dragging = false

var zoom_speed = 0.05
var min_zoom = 0.05
var max_zoom = 2

func _input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				camera_start_position = position
				mouse_start_pos = event.position
				dragging = true
			else:
				dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if (zoom.x < max_zoom):
				zoom += zoom * zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if (zoom.x > min_zoom):
				zoom -= zoom * zoom_speed
	elif event is InputEventMouseMotion:
		if dragging:
			position = camera_start_position + ((mouse_start_pos - event.position) * (1 / zoom.x))
