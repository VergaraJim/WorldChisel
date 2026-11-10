extends Node

var mapName: String
var mapFile: String

var tiles = {}
var mapWidth
var mapHeight

enum RendererType {TWO_DIMENSIONAL, THREE_DIEMNSIONAL}
var defaultRenderer = RendererType.TWO_DIMENSIONAL
var currentRenderer

var renderer2D = preload("res://scenes/components/2d_renderer.tscn")

func _ready():
	print("HI")
	if (!mapName or !mapFile):
		print("ERROR")
	# Load tiles
	loadTiles()
	# Load tile values
	# Load renderer
	startRenderer()
	pass

func loadTiles():
	print("Loading tiles")
	var file = FileAccess.open(mapFile, FileAccess.READ)
	var saveContent = file.get_as_text()
	var saveObject = JSON.parse_string(saveContent)
	mapWidth = int(saveObject["width"])
	mapHeight = int(saveObject["height"])
	for preTile in saveObject["tiles"]:
		var tileKey = str(int(preTile["x"])) + "|" + str(int(preTile["y"]))
		tiles[tileKey] = Classes.Tile.new(int(preTile["x"]),int(preTile["y"]),int(preTile["type"]))
	
func startRenderer():
	print("Starting renderer")
	var renderer = defaultRenderer
	
	if (renderer == RendererType.TWO_DIMENSIONAL):
		currentRenderer = renderer2D.instantiate()
		add_child(currentRenderer)
	print("TEST")
	currentRenderer.renderUpdate(tiles)
