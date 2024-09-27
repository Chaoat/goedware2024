extends Node2D

@export var boardWidth : int = 10
@export var boardHeight : int = 10

var tileWidth = 0
var tileHeight = 0

var boardArray = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(boardWidth):
		boardArray.append([])
		boardArray[x].resize(boardHeight)

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
				tile.position.x = coords[0]
				tile.position.y = coords[1]

func _process(dt: float) -> void:
	_updateTiles(dt)

#Returns the displaced tile if there is one
func placeTile(tile: Tile, x: int, y: int) -> Tile:
	x = min(max(x, 0), boardWidth - 1)
	y = min(max(y, 0), boardHeight - 1)
	
	var displacedTile = boardArray[x][y]
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

func highlightTiles(tiles: Array):
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
	$wordHighlight.position.x = centerX*tileWidth
	$wordHighlight.position.y = centerY*tileHeight
	$wordHighlight.material.set_shader_parameter("splits", tiles.size())
	$wordHighlight.scale.x = 4*tiles.size() + 4
	
	if height > width:
		$wordHighlight.rotation = PI/2

func getTile(x: int, y: int) -> Tile:
	if x >= 0 and x < boardWidth and y >= 0 and y < boardHeight:
		return boardArray[x][y]
	return null

func getTileAtBoardCoords(coords: Vector2) -> Tile:
	var posInBoardSpace = coords - position
	var indices = _boardCoordsToIndex(posInBoardSpace.x, posInBoardSpace.y)
	return getTile(indices[0], indices[1])
