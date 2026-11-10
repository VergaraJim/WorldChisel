extends Node2D

var tilesAtlas = {
	Classes.TileType.OCEAN: Vector2i(0,0),
	Classes.TileType.SHALLOW_WATER: Vector2i(1,0),
	Classes.TileType.LAND: [Vector2i(0,1),Vector2i(0,2),Vector2i(0,3),Vector2i(0,4)],
	Classes.TileType.FOREST: Vector2i(1,1),
	Classes.TileType.HILL: Vector2i(2,1),
	Classes.TileType.DESERT: Vector2i(3,1),
	Classes.TileType.MOUNTAIN: Vector2i(4,1)
}

func renderUpdate(tiles: Dictionary):
	for tileKey in tiles.keys():
		var tile = tiles[tileKey]
		var tileAtlasTile = tilesAtlas[tile.type]
		if tileAtlasTile is Array:
			$TileMap.set_cell(Vector2(tile.x,tile.y), 0, tileAtlasTile[randi_range(0, tileAtlasTile.size() - 1)])
		else:
			$TileMap.set_cell(Vector2(tile.x,tile.y), 0, tileAtlasTile)
