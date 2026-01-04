extends Node2D

const tileBase = preload("res://scenes/components/tile.tscn")
var editorMenu

var container: Node2D
var mainCamera: Camera2D

var map_width = 40
var map_height = 40

var tiles: Array[Classes.Tile] = []

## START UP
func _ready():
	mainCamera = get_node("MainCamera")
	container = get_node("TileContainer")
	editorMenu = get_node("MainCamera/CanvasLayer/EditorMenu")
	mapSizeChange()
	renderTiles()
	## Initial camera placement
	## TODO
	## Set map size
	$MainCamera/CanvasLayer/EditorMenu.width = map_width
	$MainCamera/CanvasLayer/EditorMenu.height = map_height

##
func renderTiles():
	## Clear all children
	container.get_children().map(func(child): child.queue_free())
	## Render the tiles
	for tile in tiles:
		renderTile(tile)

func renderTile(tile: Classes.Tile):
	var nodeName = str(tile.x) + "|" + str(tile.y)
	var oldTileNode = $TileContainer.get_node_or_null(nodeName)
	if (oldTileNode):
		oldTileNode.queue_free()
	var tileInstance = tileBase.instantiate()
	tileInstance.position = Vector2(tile.x * Constants.tileSize, tile.y * Constants.tileSize)
	tileInstance.scale = Vector2(Constants.tileSize, Constants.tileSize)
	tileInstance.get_node("Sprite").modulate = Classes.TileTypeColor[tile.type]
	tileInstance.name = nodeName
	tileInstance.connect("onClick", func(): tileClickEvent(tile))
	container.add_child(tileInstance)

func tileClickEvent(tile: Classes.Tile):
	var selectedType = editorMenu.selectedTileType
	if selectedType != null:
		var tileIndex = tiles.find(tile)
		tile.type = selectedType
		## TODO: Check if it's necessary to do this, i think it may be referencable, thus no need to update the array object
		tiles[tileIndex] = tile
		renderTile(tile)

func mapSizeChange():
	var tempTiles: Array[Classes.Tile] = []
	for x in range(map_width):
		for y in range(map_height):
			var oldTileIndex = tiles.find_custom(func(tempTile : Classes.Tile): return tempTile.x == x && tempTile.y == y)
			var tile = null
			if (oldTileIndex != -1):
				# If i found the old tile, then use that.
				tile = tiles[oldTileIndex]
			else:
				# If no old tile was found, create a new one.
				tile = Classes.Tile.new(x,y,Classes.TileType.OCEAN)
			tempTiles.append(tile)
	tiles.clear()
	tiles = tempTiles

func _on_editor_menu_size_change_apply(width: int, height: int) -> void:
	map_width = width
	map_height = height
	mapSizeChange()
	renderTiles()
