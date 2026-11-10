extends Control
var menuList = ["MainButtons","MapMenu","StartMenu"]
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
	loadMapList()
	_debug_stuff()
	# var timer = get_tree().create_timer(0.5)
	# timer.timeout.connect(startMap.bind("user://maps/map1.dat", "Map1"))
	
func _debug_stuff():
	await get_tree().create_timer(0.1).timeout
	startMap("user://maps/map1.dat", "Map1")

func loadMapList():
	var mapsDirPath = "user://maps/"
	var mapFiles = []
	var dir = DirAccess.open(mapsDirPath)
	if dir:
		# get_files() returns only filenames, excluding subfolders
		mapFiles = dir.get_files()
	else:
		print("An error occurred when trying to access the path.")
		
	const mapPanelBase = preload("res://scenes/components/map_panel.tscn")
	
	for mapFile in mapFiles:
		if mapFile != "temp.tmp.dat":
			var path = mapsDirPath+mapFile
			if FileAccess.file_exists(path):
				var file = FileAccess.open(path, FileAccess.READ)
				var saveContent = file.get_as_text()
				var saveObject = JSON.parse_string(saveContent)
				var mapName = saveObject["name"]
				var mapSize = str(int(saveObject["width"])) + "x" + str(int(saveObject["height"]))
				var mapPanelInstance = mapPanelBase.instantiate()
				mapPanelInstance.connect("onPressed", func():
					# Load function
					editMap(path, mapName)
					)
				mapPanelInstance.mapName = mapName
				mapPanelInstance.mapSize = mapSize
				mapPanelInstance.mapFile = path
				$MapMenu/GridContainer/PanelContainer/ScrollContainer/MapListContainer.add_child(mapPanelInstance)
	
	for mapFile in mapFiles:
		if mapFile != "temp.tmp.dat":
			var path = mapsDirPath+mapFile
			if FileAccess.file_exists(path):
				var file = FileAccess.open(path, FileAccess.READ)
				var saveContent = file.get_as_text()
				var saveObject = JSON.parse_string(saveContent)
				var mapName = saveObject["name"]
				var mapSize = str(int(saveObject["width"])) + "x" + str(int(saveObject["height"]))
				var mapPanelInstance = mapPanelBase.instantiate()
				mapPanelInstance.connect("onPressed", func():
					# Load function
					startMap(path, mapName)
					)
				mapPanelInstance.mapName = mapName
				mapPanelInstance.mapSize = mapSize
				mapPanelInstance.mapFile = path
				$StartMenu/GridContainer/PanelContainer/ScrollContainer/StartListContainer.add_child(mapPanelInstance)

func _on_add_new_map_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn");

func _on_back_button_pressed() -> void:
	activeMenu = menuList[0];
	updateVisibleMenu()

func _on_start_button_pressed() -> void:
	activeMenu = menuList[2];
	updateVisibleMenu()

func startMap(path, mapName):
	var gameSceneRes = preload("res://scenes/game.tscn")
	var gameScene = gameSceneRes.instantiate()
	gameScene.mapFile = path
	gameScene.mapName = mapName
	var root = get_tree().root
	var currentScene = get_tree().current_scene
	root.add_child(gameScene)
	get_tree().current_scene = gameScene
	currentScene.queue_free()

func editMap(path, mapName):
	var editorSceneRes = preload("res://scenes/editor.tscn")
	var editorScene = editorSceneRes.instantiate()
	editorScene.mapFile = path
	editorScene.mapName = mapName
	var root = get_tree().root
	var currentScene = get_tree().current_scene
	root.add_child(editorScene)
	get_tree().current_scene = editorScene
	currentScene.queue_free()
