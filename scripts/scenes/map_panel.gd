extends PanelContainer

var mapName: String
var mapSize: String
var mapFile: String

var mouseInside: bool = false

func _ready() -> void:
	$VBoxContainer/HBoxContainer/MapName.text = mapName
	$VBoxContainer/HBoxContainer/MapSize.text = mapSize
	$VBoxContainer/MapFile.text = mapFile

signal onPressed()

func _on_mouse_entered() -> void:
	mouseInside = true

func _on_mouse_exited() -> void:
	mouseInside = false

func _input(event: InputEvent) -> void:
	if (mouseInside):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				onPressed.emit()
