extends Control

@export var tileTemplate : PackedScene
var tileWidth = 0
var tileHeight = 0

var tileBag : TileBag
var tilesInHand = []
var tileOnCursor : Tile

class TileBag:
	var numberOfLetters = 0
	var tilesLeft = 0
	var tilesInBag = []
	var letterToScore = []
	
	func _defineLetter(number, score):
		tilesLeft = tilesLeft + number
		tilesInBag.append(number)
		letterToScore.append(score)
		numberOfLetters = numberOfLetters + 1
	
	func _init():
		_defineLetter(16, 1) #a
		_defineLetter(4, 3) #b
		_defineLetter(6, 3) #c
		_defineLetter(8, 2) #d
		_defineLetter(24, 1) #e
		_defineLetter(4, 4) #f
		_defineLetter(5, 2) #g
		_defineLetter(5, 4) #h
		_defineLetter(13, 1) #i
		_defineLetter(2, 8) #j
		_defineLetter(2, 5) #k
		_defineLetter(7, 1) #l
		_defineLetter(6, 3) #m
		_defineLetter(13, 1) #n
		_defineLetter(15, 1) #o
		_defineLetter(3, 4) #p
		_defineLetter(2, 10) #q
		_defineLetter(13, 1) #r
		_defineLetter(10, 1) #s
		_defineLetter(15, 1) #t
		_defineLetter(7, 1) #u
		_defineLetter(3, 4) #v
		_defineLetter(4, 4) #w
		_defineLetter(2, 8) #x
		_defineLetter(4, 4) #y
		_defineLetter(1, 10) #z
	
	func returnTile(tile: Tile):
		var index = WordDictionary.letterToIndex(tile.letter)
		tilesInBag[index] = tilesInBag[index] + 1
		tilesLeft = tilesLeft + 1
	
	func pullTile() -> Array:
		if tilesLeft > 0:
			var randomChoice = randi() % tilesLeft
			var letter
			var score
			for i in range(numberOfLetters):
				var nLetters = tilesInBag[i]
				if nLetters >= randomChoice:
					letter = WordDictionary.indexToLetter(i)
					score = letterToScore[i]
					tilesInBag[i] = tilesInBag[i] - 1
					break
				else:
					randomChoice = randomChoice - nLetters
			tilesLeft = tilesLeft - 1
			return [letter, score]
		return []

func _initTileDimensions():
	var tempTile = tileTemplate.instantiate()
	for child in tempTile.get_children():
		if child is Sprite2D:
			tileWidth = max(tileWidth, ceil(child.get_transform().get_scale().x * child.get_rect().size.x))
			tileHeight = max(tileHeight, ceil(child.get_transform().get_scale().y * child.get_rect().size.y))
	print("tile width: ",tileWidth," tile height: ",tileHeight)
	tempTile.queue_free()
	
	$board.tileWidth = tileWidth
	$board.tileHeight = tileHeight

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initTileDimensions()
	tileBag = TileBag.new()
	for i in range(0,11):
		drawRandomTile()

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
	var tile = $board.getTileAtBoardCoords(clickPos)
	if tile != null:
		_putTileOnCursor(tile)
		tile.takeOffGrid()
		return true
	return false

func _dropCursorTile(clickPos: Vector2):
	if tileOnCursor != null:
		var posInHandSpace = clickPos - $hand.position
		if posInHandSpace.y < -tileHeight:
			var posInBoardSpace = clickPos - $board.position
			var displacedTile = $board.placeTileAtBoardCoords(tileOnCursor, clickPos)
			_checkValidWordFromTile(tileOnCursor)
			if displacedTile != null:
				addTileToHand(displacedTile)
			tileOnCursor = null
			return
		addTileToHand(tileOnCursor)
		tileOnCursor = null

func _checkValidWordFromTile(tile):
	if tile.onGrid == false:
		return
	var horizontalTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, 1, 0)
	var verticalTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, 0, 1)
	
	if horizontalTiles.size() > 1:
		var horizontalString = String()
		for horizTile in horizontalTiles:
			horizontalString = horizontalString + horizTile.letter
		if $dictionary.getWordDefinitions(horizontalString).size() > 0:
			$board.highlightTiles(horizontalTiles)
	
	if verticalTiles.size() > 1:
		var verticalString = String()
		for vertTile in verticalTiles:
			verticalString = verticalString + vertTile.letter
		if $dictionary.getWordDefinitions(verticalString).size() > 0:
			$board.highlightTiles(verticalTiles)

func _addTile(letter, score) -> Tile:
	var tile = tileTemplate.instantiate()
	tile.setStats(letter, score)
	add_child(tile)
	return tile

func _input(event):
	if event is InputEventMouseButton:
		var clickPos = _mousePosToLocalPos(event.position)
		if event.is_action_pressed("placeTile"):
			if _checkHandTileClicked(clickPos) == false:
				_checkBoardTileClicked(clickPos)
		elif event.is_action_released("placeTile"):
			_dropCursorTile(clickPos)

func addTileToHand(tile: Tile) -> Tile:
	tile.reparent($hand)
	
	var handIndex = ceil((tilesInHand.size() - 1)/2 + tile.position.x/tileWidth)
	handIndex = max(min(handIndex, tilesInHand.size()), 0)
	print(handIndex)
	tilesInHand.insert(handIndex, tile)
	
	return tile

func drawRandomTile() -> Tile:
	var tileStats = tileBag.pullTile()
	if tileStats.is_empty():
		return null
	return addTileToHand(_addTile(tileStats[0], tileStats[1]))
