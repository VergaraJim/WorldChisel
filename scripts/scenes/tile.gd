extends Node2D

var bright_color = Color(1.353, 1.353, 1.353, 1.0) 
var normal_color = Color(1, 1, 1)

func _on_area_2d_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite, "self_modulate", bright_color, 0.1)

func _on_area_2d_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite, "self_modulate", normal_color, 0.3)

signal onClick

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			onClick.emit()
