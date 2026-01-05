extends Node
class_name Generator

var dropOff = 0.1
var widthRadius: int
var heightRadius: int
var widthMultiplierMap = {}
var heightMultiplierMap = {}

enum TileLevel {OCEAN,SHALLOW,LAND,HILL,MOUNTAIN}
enum TileClimate {EXTREME_HOT, HOT, TEMPERATE, COLD, EXTREME_COLD}
enum TileHumidity {HIGH, TEMPERATE, LOW}

func generate(width: int, height: int, selectedSeed: int):
	# Border easing variables
	widthRadius = floor(width * dropOff)
	heightRadius = floor(height * dropOff)
	widthMultiplierMap.clear()
	heightMultiplierMap.clear()
	for i in range(widthRadius):
		widthMultiplierMap[i] = 0.0 + (1.0 * (float(i) / widthRadius))
	for i in range(heightRadius):
		heightMultiplierMap[i] = 0.0 + (1.0 * (float(i) / heightRadius))
	
	var tiles = {}
	
	var noiseMap = FastNoiseLite.new()
	noiseMap.seed = selectedSeed
	noiseMap.frequency = 0.01
	noiseMap.noise_type = FastNoiseLite.TYPE_PERLIN
	noiseMap.fractal_octaves = 5
	noiseMap.fractal_gain = 0.5
	
	var noiseMap2 = FastNoiseLite.new()
	noiseMap2.seed = selectedSeed * 2
	noiseMap2.frequency = 0.01
	noiseMap2.noise_type = FastNoiseLite.TYPE_PERLIN
	noiseMap2.fractal_octaves = 3
	noiseMap2.fractal_gain = 0.5
	
	var noiseMap3 = FastNoiseLite.new()
	noiseMap3.seed = selectedSeed * 3
	noiseMap3.frequency = 0.025
	noiseMap3.noise_type = FastNoiseLite.TYPE_PERLIN
	noiseMap3.fractal_octaves = 3
	noiseMap3.fractal_gain = 0.5
	
	var defaultTileType = Classes.TileType.OCEAN
	
	for x in range(width):
		for y in range(height):
			var tile = Classes.Tile.new(x,y,defaultTileType)
			var borderMultiplier = calculateBorderMultiplier(x,y,width,height)
			var noise1 = noiseMap.get_noise_2d(x,y) # Main
			var noise2 = noiseMap2.get_noise_2d(x,y) # Sculpting
			var noise3 = noiseMap3.get_noise_2d(x,y) # Sculpting
			var altitudeNoise = (noise1 + (noise2 / 5)) * borderMultiplier
			
			var level: TileLevel
			
			if (altitudeNoise > 0.35):
				level = TileLevel.MOUNTAIN
			elif (altitudeNoise > 0.3):
				level = TileLevel.HILL
			elif (altitudeNoise > 0.1):
				level = TileLevel.LAND
			elif (altitudeNoise > 0.05):
				level = TileLevel.SHALLOW
			else:
				level = TileLevel.OCEAN
				
			var climate: TileClimate
			
			var equatorY = y if (y <= float(width)/2) else (width - y)
			var equatorDistance = 1.0 - float(equatorY) / (float(width) / 2)
			var distancePlusAltitude = ((equatorDistance * 3) + (altitudeNoise / 0.5)) / 4
			if (distancePlusAltitude > 0.62):
				climate = TileClimate.EXTREME_COLD
				#tile.type = Classes.TileType.MOUNTAIN
			elif (distancePlusAltitude > 0.48):
				climate = TileClimate.COLD
				#tile.type = Classes.TileType.HILL
			elif (distancePlusAltitude > 0.33):
				climate = TileClimate.TEMPERATE
				#tile.type = Classes.TileType.LAND
			elif (distancePlusAltitude > 0.15):
				climate = TileClimate.HOT
				#tile.type = Classes.TileType.SHALLOW_WATER
			else:
				climate = TileClimate.EXTREME_HOT
				#tile.type = Classes.TileType.OCEAN
				
			var humidity: TileHumidity
			
			# var humidityLevel = (altitudeNoise + noise2 * 2) / 3
			var humidityLevel = noise3
			if (humidityLevel > 0.15):
				humidity = TileHumidity.HIGH
			elif (humidityLevel > -0.15):
				humidity = TileHumidity.TEMPERATE
			else:
				humidity = TileHumidity.LOW
			
			if (level == TileLevel.MOUNTAIN):
				tile.type = Classes.TileType.MOUNTAIN
			elif (level == TileLevel.OCEAN):
				tile.type = Classes.TileType.OCEAN
			elif (level == TileLevel.SHALLOW):
				tile.type = Classes.TileType.SHALLOW_WATER
			elif (level == TileLevel.HILL):
				tile.type = Classes.TileType.HILL
			else:
				tile.type = Classes.TileType.LAND
				if climate == TileClimate.EXTREME_HOT:
					if humidity in [TileHumidity.LOW, TileHumidity.TEMPERATE]:
						tile.type = Classes.TileType.DESERT
					if humidity in [TileHumidity.HIGH]:
						tile.type = Classes.TileType.FOREST
				if climate == TileClimate.HOT:
					if humidity in [TileHumidity.LOW]:
						tile.type = Classes.TileType.DESERT
					if humidity in [TileHumidity.HIGH]:
						tile.type = Classes.TileType.FOREST
				if climate == TileClimate.TEMPERATE:
					if humidity in [TileHumidity.HIGH, TileHumidity.TEMPERATE]:
						tile.type = Classes.TileType.FOREST
				if climate == TileClimate.COLD:
					pass
				if climate == TileClimate.EXTREME_COLD:
					pass
			tiles[tile.getKey()] = tile
	return tiles


func calculateBorderMultiplier(x: int, y: int, width: int, height: int):
	var multiplier = 1
	if (x in widthMultiplierMap):
		multiplier *= widthMultiplierMap[x]
	elif (width - x in widthMultiplierMap):
		multiplier *= widthMultiplierMap[width - x]
	if (y in heightMultiplierMap):
		multiplier *= heightMultiplierMap[y]
	elif (height - y in heightMultiplierMap):
		multiplier *= heightMultiplierMap[height - y]
	return multiplier
