extends Node2D

var actionHistory = []

var mapName = ""
var mapFile

const tileBase = preload("res://scenes/components/tile.tscn")
var editorMenu

var container: Node2D
var mainCamera: Camera2D

var map_width = 100
var map_height = 100

var tiles = {}
var isPlacingTile: bool = false
var filteredTile = null
var isFilteredPlacing: bool = false

var tilePlacingCooldownBase = 1
var tilePlacingCooldown = 0

## START UP
func _ready():
	mainCamera = get_node("MainCamera")
	container = get_node("TileContainer")
	editorMenu = get_node("MainCamera/CanvasLayer/EditorMenu")
	if !mapFile:
		loadDataFromFile("temp.tmp")
	mapSizeChange()
	fullRenderTiles()
	## Initial camera placement
	## TODO
	## Set map size
	$MainCamera/CanvasLayer/EditorMenu.width = map_width
	$MainCamera/CanvasLayer/EditorMenu.height = map_height

func _physics_process(_delta: float) -> void:
	if tilePlacingCooldown > 0:
		tilePlacingCooldown -= 1

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				isPlacingTile = true
			else:
				isPlacingTile = false
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			if (event.is_pressed()):
				isFilteredPlacing = true
			else:
				isFilteredPlacing = false
		if event.keycode == KEY_Z and event.is_pressed() and event.ctrl_pressed:
			undoAction()
		if event.keycode == KEY_ESCAPE:
			$MainCamera/CanvasLayer/EditorMenu.openExitScreen()
		if event.keycode == KEY_S and event.ctrl_pressed:
			$MainCamera/CanvasLayer/EditorMenu.openSaveScreen()
	if !isFilteredPlacing:
		filteredTile = null

func fullRenderTiles():
	## Clear all children
	var oldNodes = container.get_children()
	for oldNode in oldNodes:
		if !(tiles.has(oldNode.name)):
			container.remove_child(oldNode)
			oldNode.queue_free()
	## Render the tiles
	for tileKey in tiles.keys():
		renderTile(tileKey)

func renderTile(tileKey: String):
	saveToTemp()
	var tile = tiles[tileKey]
	var oldTileNode = container.get_node_or_null(tileKey)
	var currentTile
	if (oldTileNode and is_instance_valid(oldTileNode)):
		currentTile = oldTileNode
	else:
		currentTile = tileBase.instantiate()
		currentTile.position = Vector2(tile.x * Constants.tileSize, tile.y * Constants.tileSize)
		currentTile.scale = Vector2(Constants.tileSize, Constants.tileSize)
		currentTile.name = tileKey
		currentTile.connect("onHover", func(): tileHoverEvent(tile))
		container.add_child(currentTile)
	currentTile.get_node("Sprite").modulate = Classes.TileTypeColor[tile.type]

var currentActionTilesChanged = {}

# This is the tile placing function
func tileHoverEvent(tile: Classes.Tile):
	# Check if placing tile (AKA clicking left)
	if isPlacingTile:
		if (isFilteredPlacing and filteredTile == null):
			filteredTile = tile.type
		var selectedType = editorMenu.selectedTileType
		var brushSize = editorMenu.tileEditBrushSize
		# Check if placing tile is in cooldown and selectedType of tile is not null
		if selectedType != null && tilePlacingCooldown == 0:
			tilePlacingCooldown = tilePlacingCooldownBase
			var editedTiles = []
			## Brush size effect
			for x in range(brushSize):
				for y in range(brushSize):
					var offsetTopLeft = ((brushSize - 1) / 2)
					var currentX = x - offsetTopLeft + tile.x
					var currentY = y - offsetTopLeft + tile.y
					var extraTileKey = str(currentX)+"|"+str(currentY)
					var extraTile = tiles[extraTileKey] if tiles.has(extraTileKey) else null
					if (extraTile):
						if (!isFilteredPlacing or ((extraTile.type == filteredTile) or (filteredTile == null))):
							# Insert into the action history
							if !currentActionTilesChanged.has(extraTile.getKey()):
								currentActionTilesChanged[extraTile.getKey()] = extraTile.type
							# Change the tile
							extraTile.type = selectedType
							editedTiles.append(extraTileKey)
			for editedTileKey in editedTiles:
				renderTile(editedTileKey)
	elif currentActionTilesChanged.size() > 0:
		actionHistory.append(currentActionTilesChanged.duplicate())
		currentActionTilesChanged.clear()

func undoAction():
	if (actionHistory.size() > 0):
		var lastAction = actionHistory.pop_back()
		for tileKey in lastAction.keys():
			tiles[tileKey].type = lastAction[tileKey]
			renderTile(tileKey)

func mapSizeChange():
	var defaultTile = Classes.TileType.OCEAN
	var tempTiles = {}
	
	for x in range(map_width):
		for y in range(map_height):
			var dictKey = str(x)+"|"+str(y)
			var oldTile = tiles[dictKey] if tiles.has(dictKey) else null
			var tile = null
			if (oldTile):
				# If i found the old tile, then use that.
				tile = oldTile
			else:
				# If no old tile was found, create a new one.
				tile = Classes.Tile.new(x,y,defaultTile)
			tempTiles[tile.getKey()] = tile
	tiles.clear()
	tiles = tempTiles

func _on_editor_menu_size_change_apply(width: int, height: int) -> void:
	map_width = width
	map_height = height
	mapSizeChange()
	fullRenderTiles()

# This function, due to the debounce timer, will only execute after 1 seconds after it is called, cancels old requests.
var saveTmpDebounceTimer: SceneTreeTimer
func saveToTemp():
	if saveTmpDebounceTimer:
		saveTmpDebounceTimer.timeout.disconnect(saveDataToFile)
		
	saveTmpDebounceTimer = get_tree().create_timer(1.0)
	saveTmpDebounceTimer.timeout.connect(saveDataToFile.bind("temp.tmp"))

func _on_editor_menu_randomize_map_apply(seedValue: String) -> void:
	generateMap(seedValue)

func generateMap(seedValue: String):
	var selectedSeed: int
	if seedValue:
		if seedValue.is_valid_int():
			selectedSeed = seedValue.to_int()
		else:
			selectedSeed = seedValue.hash()
	else:
		selectedSeed = randi_range(100_000_000, 999_000_000)
	
	var generator = Generator.new()
	var generatedTiles = generator.generate(map_width,map_height,selectedSeed)
	
	tiles = generatedTiles
	fullRenderTiles()

func _on_editor_menu_exit_no_save() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn");

func _on_editor_menu_exit_save(filename: String) -> void:
	saveDataToFile(filename)
	get_tree().change_scene_to_file("res://scenes/menu.tscn");

func saveDataToFile(savingMapName: String):
	var path = "user://maps/" + savingMapName.to_lower().replace(" ", "_") + ".dat"
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var data = {
		"name": savingMapName,
		"width": map_width,
		"height": map_height,
		"tiles": []
	}
	
	for tileKey in tiles.keys():
		var tile = tiles[tileKey]
		data["tiles"].append(tile._to_dict())
	
	file.store_line(JSON.stringify(data))

func loadDataFromFile(savingMapName):
	var path = "user://maps/" + savingMapName.to_lower().replace(" ", "_") + ".dat" if !mapFile else mapFile
	if (FileAccess.file_exists(path)):
		var tempFile = FileAccess.open(path, FileAccess.READ)
		var saveContent = tempFile.get_as_text()
		var saveObject = JSON.parse_string(saveContent)
		
		if savingMapName != "temp.tmp":
			mapName = saveObject["name"]
			$MainCamera/CanvasLayer/EditorMenu/SaveScreen/PanelContainer/VBoxContainer/SaveName.name = mapName
		
		map_width = saveObject["width"]
		map_height = saveObject["height"]
		
		tiles.clear()
		for savedTile in saveObject["tiles"]:
			var key = str(int(savedTile.x))+"|"+str(int(savedTile.y))
			var tile = Classes.Tile.new(savedTile["x"],savedTile["y"],savedTile["type"])
			tiles[key] = tile
