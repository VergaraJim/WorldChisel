extends Control
var menuList = ["MainButtons","MapMenu"]
var activeMenu = "MainButtons"

func _on_button_button_up() -> void:
	activeMenu = menuList[1];
	updateVisibleMenu()

func _on_back_button_button_up() -> void:
	activeMenu = menuList[0];
	updateVisibleMenu()

func updateVisibleMenu():
	for menu in menuList:
		get_node(menu).visible = false
	get_node(activeMenu).visible = true

func _ready() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn");
