extends Node2D

const tileBase = preload("res://scenes/components/tile.tscn")

var container: Node2D
var mainCamera: Camera2D

var map_width = 40
var map_height = 40

var tiles: Array[Classes.Tile] = []

## START UP
func _ready():
	mainCamera = get_node("MainCamera")
	container = get_node("TileContainer")
	for x in range(map_width):
		for y in range(map_height):
			var tile = Classes.Tile.new(x,y,Classes.TileType.OCEAN)
			tiles.append(tile)
	renderTiles()
	## Initial camera placement
	## TODO

##
func renderTiles():
	for tile in tiles:
		var tileInstance = tileBase.instantiate()
		tileInstance.position = Vector2(tile.x * Constants.tileSize, tile.y * Constants.tileSize)
		tileInstance.scale = Vector2(Constants.tileSize, Constants.tileSize)
		tileInstance.get_node("Sprite").modulate = Classes.TileTypeColor[tile.type]
		container.add_child(tileInstance)
