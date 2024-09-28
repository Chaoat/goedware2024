extends Node2D

@export var boardWidth : int = 10
@export var boardHeight : int = 10

@export var highlightTemplate : PackedScene

var endZone : Array = [[2,3], [3,3], [3,4], [4,4]]

var tileWidth = 0
var tileHeight = 0

var boardArray = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(boardWidth):
		boardArray.append([])
		boardArray[x].resize(boardHeight)

func _draw():
	for x in range(boardWidth):
		for y in range(boardHeight):
			draw_rect(Rect2((x - 0.5)*tileWidth, (y - 0.5)*tileHeight, tileWidth, tileHeight), Color.RED, false)

func _indexToBoardCoords(x: int, y: int) -> Array:
	return [x*tileWidth, y*tileHeight]

func _boardCoordsToIndex(x: int, y: int) -> Array:
	return [ceil(x/tileWidth - 0.5), ceil(y/tileHeight - 0.5)]

func _updateTiles(dt: float):
	for x in range(boardWidth):
		for y in range(boardHeight):
			var tile:Tile = boardArray[x][y]
			if tile != null:
				if tile.onGrid == false:
					boardArray[x][y] = null
					continue
					
				var coords = _indexToBoardCoords(x, y)
				tile.targetPos.x = coords[0]
				tile.targetPos.y = coords[1]

func _process(dt: float) -> void:
	_updateTiles(dt)

func canPlaceTileAtBoardCoords(coords: Vector2) -> bool:
	var tile = getTileAtBoardCoords(coords)
	return tile == null or tile.confirmed == false

#Returns the displaced tile if there is one
func placeTile(tile: Tile, x: int, y: int) -> Tile:
	x = min(max(x, 0), boardWidth - 1)
	y = min(max(y, 0), boardHeight - 1)
	
	var displacedTile = boardArray[x][y]
	if displacedTile != null and displacedTile.confirmed:
		return null
	
	boardArray[x][y] = tile
	tile.reparent(self)
	tile.placedOnGrid(x, y)
	
	if displacedTile != null:
		displacedTile.takeOffGrid()
		return displacedTile
	return null
	
func placeTileAtBoardCoords(tile: Tile, coords: Vector2) -> Tile:
	var posInBoardSpace = coords - position
	var indices = _boardCoordsToIndex(posInBoardSpace.x, posInBoardSpace.y)
	return placeTile(tile, indices[0], indices[1])

func getContiguousTiles(x: int, y: int, xDir: int, yDir: int) -> Array:
	var lastTile = getTile(x, y)
	while lastTile != null:
		x = x - xDir
		y = y - yDir
		lastTile = getTile(x, y)
	x = x + xDir
	y = y + yDir
	
	var returnTiles = []
	var nextTile = getTile(x, y)
	while nextTile != null:
		returnTiles.append(nextTile)
		x = x + xDir
		y = y + yDir
		nextTile = getTile(x, y)
	return returnTiles

func highlightTiles(tiles: Array, colour: Vector4) -> Sprite2D:
	var minX = tiles[0].gridX
	var minY = tiles[0].gridY
	var maxX = tiles[0].gridX
	var maxY = tiles[0].gridY
	for i in range(1, tiles.size()):
		var tile = tiles[i]
		minX = min(minX, tile.gridX)
		minY = min(minY, tile.gridY)
		maxX = max(maxX, tile.gridX)
		maxY = max(maxY, tile.gridY)
	
	var width = maxX - minX
	var height = maxY - minY
	var centerX = minX + width/2.0
	var centerY = minY + height/2.0
	
	var newHighlight:Sprite2D = highlightTemplate.instantiate()
	add_child(newHighlight)
	
	newHighlight.position.x = centerX*tileWidth
	newHighlight.position.y = centerY*tileHeight
	newHighlight.material.set_local_to_scene(true)
	newHighlight.material.set_shader_parameter("splits", tiles.size())
	newHighlight.material.set_shader_parameter("colour", colour)
	newHighlight.scale.x = tiles.size() + 1
	
	if height > width:
		newHighlight.rotation = PI/2
	
	return newHighlight

func getTile(x: int, y: int) -> Tile:
	if x >= 0 and x < boardWidth and y >= 0 and y < boardHeight:
		if boardArray[x][y] != null and boardArray[x][y].onGrid == true:
			return boardArray[x][y]
	return null

func getTileAtBoardCoords(coords: Vector2) -> Tile:
	var posInBoardSpace = coords - position
	var indices = _boardCoordsToIndex(posInBoardSpace.x, posInBoardSpace.y)
	return getTile(indices[0], indices[1])

func getTilesInEndzone() -> Array:
	var tiles = []
	for endZoneCoord in endZone:
		var tile = getTile(endZoneCoord[0], endZoneCoord[1])
		if tile != null:
			tiles.append(tile)
	return tiles

func isTileInEndzone(tile: Tile) -> bool:
	for endZoneCoord in endZone:
		if tile.gridX == endZoneCoord[0] and tile.gridY == endZoneCoord[1]:
			return true
	return false

func pathfindBetweenTiles(tile1:Tile, tile2:Tile) -> Array:
	var checkingTiles = [[tile1, null]]
	var checkedTiles = []
	
	var checkTileValid = func(tile:Tile) -> bool:
		return tile != null and tile.confirmed == true and checkedTiles.find(tile) == -1
	
	while checkingTiles.size() > 0:
		var nextTileGroup = checkingTiles.pop_front()
		var tile = nextTileGroup[0]
		
		if tile == tile2:
			var returnTiles = []
			while nextTileGroup != null:
				returnTiles.push_front(nextTileGroup[0])
				nextTileGroup = nextTileGroup[1]
			return returnTiles
		
		var leftTile = getTile(tile.gridX - 1, tile.gridY)
		if checkTileValid.call(leftTile):
			checkingTiles.append([leftTile, nextTileGroup])
		var topTile = getTile(tile.gridX, tile.gridY - 1)
		if checkTileValid.call(topTile):
			checkingTiles.append([topTile, nextTileGroup])
		var rightTile = getTile(tile.gridX + 1, tile.gridY)
		if checkTileValid.call(rightTile):
			checkingTiles.append([rightTile, nextTileGroup])
		var bottomTile = getTile(tile.gridX, tile.gridY + 1)
		if checkTileValid.call(bottomTile):
			checkingTiles.append([bottomTile, nextTileGroup])
		checkedTiles.append(tile)
	return []
