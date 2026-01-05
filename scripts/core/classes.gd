extends Node

enum TileType {OCEAN,SHALLOW_WATER,LAND,FOREST,DESERT,HILL,MOUNTAIN}

var TileTypeColor = {
	TileType.OCEAN: Color.DARK_BLUE,
	TileType.SHALLOW_WATER: Color.AQUA,
	TileType.LAND: Color.SEA_GREEN,
	TileType.FOREST: Color.DARK_GREEN,
	TileType.DESERT: Color.SANDY_BROWN,
	TileType.HILL: Color.DARK_SEA_GREEN,
	TileType.MOUNTAIN: Color.WEB_GRAY,
}

class Tile:
	var x: int
	var y: int
	var type: TileType
	
	func _init(_x: int, _y: int, _type: TileType):
		x = _x
		y = _y
		type = _type
		
	func _to_dict() -> Dictionary:
		return { "x": x, "y": y, "type": type }
	
	func getKey() -> String:
		return str(x)+"|"+str(y)
