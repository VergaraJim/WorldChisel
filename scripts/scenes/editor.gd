extends Node2D

const tileBase = preload("res://scenes/components/tile.tscn")
var editorMenu

var container: Node2D
var mainCamera: Camera2D

var map_width = 100
var map_height = 100

var tiles = {}
var isPlacingTile: bool

var tilePlacingCooldownBase = 1
var tilePlacingCooldown = 0

## START UP
func _ready():
	mainCamera = get_node("MainCamera")
	container = get_node("TileContainer")
	editorMenu = get_node("MainCamera/CanvasLayer/EditorMenu")
	loadTempSave()
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

func tileHoverEvent(tile: Classes.Tile):
	if isPlacingTile:
		var selectedType = editorMenu.selectedTileType
		var brushSize = editorMenu.tileEditBrushSize
		if selectedType != null && tilePlacingCooldown == 0:
			tilePlacingCooldown = tilePlacingCooldownBase
			var editedTiles = []
			tile.type = selectedType
			editedTiles.append(tile.getKey())
			## Brush size effect
			for x in range(brushSize):
				for y in range(brushSize):
					var offsetTopLeft = ((brushSize - 1) / 2)
					var currentX = x - offsetTopLeft + tile.x
					var currentY = y - offsetTopLeft + tile.y
					var extraTileKey = str(currentX)+"|"+str(currentY)
					var extraTile = tiles[extraTileKey] if tiles.has(extraTileKey) else null
					if (extraTile):
						extraTile.type = selectedType
						editedTiles.append(extraTileKey)
			for editedTileKey in editedTiles:
				renderTile(editedTileKey)

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
		saveTmpDebounceTimer.timeout.disconnect(_saveDataToFileTemp)
		
	saveTmpDebounceTimer = get_tree().create_timer(1.0)
	saveTmpDebounceTimer.timeout.connect(_saveDataToFileTemp)

func _saveDataToFileTemp():
	var tempFile = FileAccess.open("user://editor.tmp", FileAccess.WRITE)
	var data = {
		"width": map_width,
		"height": map_height,
		"tiles": []
	}
	
	for tileKey in tiles.keys():
		var tile = tiles[tileKey]
		data["tiles"].append(tile._to_dict())
	
	#print(JSON.stringify(data))
	
	tempFile.store_line(JSON.stringify(data))

func loadTempSave():
	var path = "user://editor.tmp"
	return
	if (FileAccess.file_exists(path)):
		var tempFile = FileAccess.open(path, FileAccess.READ)
		var saveContent = tempFile.get_as_text()
		var saveObject = JSON.parse_string(saveContent)
		
		map_width = saveObject["width"]
		map_height = saveObject["height"]
		
		tiles.clear()
		for savedTile in saveObject["tiles"]:
			var key = str(savedTile.x)+"|"+str(savedTile.y)
			var tile = Classes.Tile.new(savedTile["x"],savedTile["y"],savedTile["type"])
			tiles[key] = tile
	
