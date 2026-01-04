extends Node2D

const tileBase = preload("res://scenes/components/tile.tscn")
var editorMenu

var container: Node2D
var mainCamera: Camera2D

var map_width = 40
var map_height = 40

var tiles: Array[Classes.Tile] = []
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
	renderTiles()
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

func renderTiles():
	## Clear all children
	container.get_children().map(func(child): child.queue_free())
	## Render the tiles
	for tile in tiles:
		renderTile(tile)

func renderTile(tile: Classes.Tile):
	saveToTemp()
	var nodeName = str(tile.x) + "|" + str(tile.y)
	var oldTileNode = $TileContainer.get_node_or_null(nodeName)
	if (oldTileNode):
		oldTileNode.queue_free()
	var tileInstance = tileBase.instantiate()
	tileInstance.position = Vector2(tile.x * Constants.tileSize, tile.y * Constants.tileSize)
	tileInstance.scale = Vector2(Constants.tileSize, Constants.tileSize)
	tileInstance.get_node("Sprite").modulate = Classes.TileTypeColor[tile.type]
	tileInstance.name = nodeName
	tileInstance.connect("onHover", func(): tileHoverEvent(tile))
	container.add_child(tileInstance)

func tileHoverEvent(tile: Classes.Tile):
	if isPlacingTile:
		var selectedType = editorMenu.selectedTileType
		var brushSize = editorMenu.tileEditBrushSize
		if selectedType != null && tilePlacingCooldown == 0:
			tilePlacingCooldown = tilePlacingCooldownBase
			var editedTiles: Array[Classes.Tile] = []
			tile.type = selectedType
			editedTiles.append(tile)
			## Brush size effect
			for x in range(brushSize):
				for y in range(brushSize):
					var offsetTopLeft = ((brushSize - 1) / 2)
					var currentX = x - offsetTopLeft + tile.x
					var currentY = y - offsetTopLeft + tile.y
					var extraTileIndex = tiles.find_custom(func(tempTile): return tempTile.x == currentX and tempTile.y == currentY)
					var extraTile = tiles[extraTileIndex]
					if (extraTile):
						extraTile.type = selectedType
						editedTiles.append(extraTile)
			for editedTile in editedTiles:
				renderTile(editedTile)

func mapSizeChange():
	var defaultTile = Classes.TileType.OCEAN
	var tileDict = {}
	var tempTiles: Array[Classes.Tile] = []
	
	for tile in tiles:
		var dictKey = str(tile.x)+"|"+str(tile.y)
		tileDict[dictKey] = tile
	
	for x in range(map_width):
		for y in range(map_height):
			## TODO: Fix this, this causes massive lag
			var dictKey = str(x)+"|"+str(y)
			var oldTile = tileDict[dictKey]
			var tile = null
			if (oldTile):
				# If i found the old tile, then use that.
				tile = oldTile
			else:
				# If no old tile was found, create a new one.
				tile = Classes.Tile.new(x,y,defaultTile)
			tempTiles.append(tile)
	tiles.clear()
	tiles = tempTiles

func _on_editor_menu_size_change_apply(width: int, height: int) -> void:
	map_width = width
	map_height = height
	mapSizeChange()
	renderTiles()

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
	
	for tile in tiles:
		data["tiles"].append(tile._to_dict())
	
	tempFile.store_line(JSON.stringify(data))

func loadTempSave():
	var path = "user://editor.tmp"
	if (FileAccess.file_exists(path)):
		var tempFile = FileAccess.open(path, FileAccess.READ)
		var saveContent = tempFile.get_as_text()
		var saveObject = JSON.parse_string(saveContent)
		
		map_width = saveObject["width"]
		map_height = saveObject["height"]
		
		tiles.clear()
		for savedTile in saveObject["tiles"]:
			var tile = Classes.Tile.new(savedTile["x"],savedTile["y"],savedTile["type"])
			tiles.append(tile)
	
