extends Control

@export var boardWidth : int = 10
@export var boardHeight : int = 10

@export var tileTemplate : PackedScene
var tileWidth = 0
var tileHeight = 0

var boardArray = []
var tilesInHand = []
var tileOnCursor : Tile

func _initTileDimensions():
	var tempTile = tileTemplate.instantiate()
	for child in tempTile.get_children():
		if child is Sprite2D:
			tileWidth = max(tileWidth, ceil(child.get_transform().get_scale().x * child.get_rect().size.x))
			tileHeight = max(tileHeight, ceil(child.get_transform().get_scale().y * child.get_rect().size.y))
	print("tile width: ",tileWidth," tile height: ",tileHeight)
	tempTile.queue_free()

func _initBoard():
	for x in range(boardWidth):
		boardArray.append([])
		boardArray[x].resize(boardHeight)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initTileDimensions()
	_initBoard()
	
	placeTile(addTile(), 3, 2)
	placeTile(addTile(), 3, 5)
	addTileToHand(addTile())
	addTileToHand(addTile())
	addTileToHand(addTile())

func _updateBoardTiles(dt: float):
	for x in range(boardWidth):
		for y in range(boardHeight):
			var tile:Tile = boardArray[x][y]
			if tile != null:
				var coords = indexToBoardCoords(x, y)
				tile.position.x = coords[0]
				tile.position.y = coords[1]

func _updateHandTiles(dt: float):
	var tileI = 0
	var nTiles = tilesInHand.size()
	for tile:Tile in tilesInHand:
		tile.position.x = (tileI - (nTiles - 1)/2.0)*tileWidth
		tile.position.y = 0
		tileI = tileI + 1

func _updateTileOnCursor(dt: float):
	if tileOnCursor != null:
		var mousePos = get_viewport().get_mouse_position()
		mousePos = _mousePosToLocalPos(mousePos)
		tileOnCursor.position.x = mousePos.x
		tileOnCursor.position.y = mousePos.y

var mousePosLastFrame;
func _updateCameraMovement(dt: float):
	if Input.is_action_pressed("moveScrabbleCamera"):
		var mouseDelta = get_viewport().get_mouse_position() - mousePosLastFrame
		$board.move_local_x(mouseDelta.x)
		$board.move_local_y(mouseDelta.y)
	mousePosLastFrame = get_viewport().get_mouse_position()

func _mousePosToLocalPos(pos: Vector2):
	return pos - global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	_updateBoardTiles(dt)
	_updateHandTiles(dt)
	_updateTileOnCursor(dt)
	_updateCameraMovement(dt)

func _putTileOnCursor(tile: Tile):
	tileOnCursor = tile
	tile.reparent(self)
	add_child(tile)

func _checkHandTileClicked(clickPos: Vector2) -> bool:
	var posInHandSpace = clickPos - $hand.position
	for i in range(tilesInHand.size()):
		var tile = tilesInHand[i]
		if posInHandSpace.x >= tile.position.x - tileWidth/2 and posInHandSpace.x <= tile.position.x + tileWidth/2 and posInHandSpace.y >= tile.position.y - tileHeight/2 and posInHandSpace.y <= tile.position.y + tileHeight/2:
			tilesInHand.remove_at(i)
			_putTileOnCursor(tile)
			return true
	return false

func _checkBoardTileClicked(clickPos: Vector2) -> bool:
	var posInBoardSpace = clickPos - $board.position
	var indices = boardCoordsToIndex(posInBoardSpace.x, posInBoardSpace.y)
	if indices[0] >= 0 and indices[0] < boardWidth and indices[1] >= 0 and indices[1] < boardHeight:
		if boardArray[indices[0]][indices[1]] != null:
			_putTileOnCursor(boardArray[indices[0]][indices[1]])
			boardArray[indices[0]][indices[1]] = null
			return true
	return false

func _dropCursorTile(clickPos: Vector2):
	if tileOnCursor != null:
		var posInHandSpace = clickPos - $hand.position
		if posInHandSpace.y < -tileHeight:
			var posInBoardSpace = clickPos - $board.position
			var indices = boardCoordsToIndex(posInBoardSpace.x, posInBoardSpace.y)
			if indices[0] >= 0 and indices[0] < boardWidth and indices[1] >= 0 and indices[1] < boardHeight:
				if boardArray[indices[0]][indices[1]] == null:
					placeTile(tileOnCursor, indices[0], indices[1])
					tileOnCursor = null
					return
		addTileToHand(tileOnCursor)
		tileOnCursor = null

func _input(event):
	if event is InputEventMouseButton:
		var clickPos = _mousePosToLocalPos(event.position)
		if event.is_action_pressed("placeTile"):
			if _checkHandTileClicked(clickPos) == false:
				_checkBoardTileClicked(clickPos)
		elif event.is_action_released("placeTile"):
			_dropCursorTile(clickPos)
			

func indexToBoardCoords(x: int, y: int) -> Array:
	return [x*tileWidth, y*tileHeight]

func boardCoordsToIndex(x: int, y: int) -> Array:
	return [ceil(x/tileWidth - 0.5), ceil(y/tileHeight - 0.5)]

func addTileToHand(tile: Tile) -> Tile:
	tilesInHand.append(tile)
	tile.reparent($hand)
	return tile

func placeTile(tile: Tile, x: int, y: int) -> Tile:
	boardArray[x][y] = tile
	tile.reparent($board)
	return tile

func addTile() -> Tile:
	var newTile = tileTemplate.instantiate()
	add_child(newTile)
	return newTile
