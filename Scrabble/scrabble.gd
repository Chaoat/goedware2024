extends Control

const dragDistanceToPickup:float = 15.0
const doubleClickTime:float = 0.2
const startingHandSize:int = 9

@export var tileTemplate : PackedScene
var tileWidth = 0
var tileHeight = 0

var tileBag : TileBag
var tilesInHand = []
var tileOnCursor : Tile

var validWords = []
var confirmedWords = []

class ValidWord:
	func _init(inputTiles):
		tiles = inputTiles
		word = ""
		for tile in tiles:
			word = word + tile.letter
	
	var tiles: Array
	var word: String
	var highlightSprite: Sprite2D

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
	for i in range(0,startingHandSize):
		drawRandomTile()

func _updateHandTiles(dt: float):
	var tileI = 0
	var nTiles = tilesInHand.size()
	for tile:Tile in tilesInHand:
		tile.targetPos.x = (tileI - (nTiles - 1)/2.0)*tileWidth
		tile.targetPos.y = 0
		tileI = tileI + 1

func _updateTileOnCursor(dt: float):
	if tileOnCursor != null:
		var mousePos = get_viewport().get_mouse_position()
		mousePos = _mousePosToLocalPos(mousePos)
		tileOnCursor.targetPos.x = mousePos.x
		tileOnCursor.targetPos.y = mousePos.y

var waitingForDragMovement: bool
var startingClickPos: Vector2
var doubleClickTimer: float
var mousePosLastFrame
func _updateMouseMovement(dt: float):
	doubleClickTimer = doubleClickTimer - dt
	if Input.is_action_pressed("moveScrabbleCamera"):
		var mouseDelta = get_viewport().get_mouse_position() - mousePosLastFrame
		$board.move_local_x(mouseDelta.x)
		$board.move_local_y(mouseDelta.y)
	if waitingForDragMovement == true:
		var mousePos: Vector2 = _mousePosToLocalPos(get_viewport().get_mouse_position())
		if startingClickPos.distance_to(mousePos) > dragDistanceToPickup:
			if _checkHandTileClicked(startingClickPos) == false:
				_checkBoardTileClicked(startingClickPos)
			waitingForDragMovement = false
	mousePosLastFrame = get_viewport().get_mouse_position()

func _mousePosToLocalPos(pos: Vector2):
	return pos - global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	_updateHandTiles(dt)
	_updateTileOnCursor(dt)
	_updateMouseMovement(dt)

func _putTileOnCursor(tile: Tile):
	tileOnCursor = tile
	tile.reparent(self)
	add_child(tile)

func _checkPointInTile(pointPos, tile) -> bool:
	return pointPos.x >= tile.position.x - tileWidth/2 and pointPos.x <= tile.position.x + tileWidth/2 and pointPos.y >= tile.position.y - tileHeight/2 and pointPos.y <= tile.position.y + tileHeight/2

func _checkHandTileClicked(clickPos: Vector2) -> bool:
	var posInHandSpace = clickPos - $hand.position
	for i in range(tilesInHand.size()):
		var tile = tilesInHand[i]
		if _checkPointInTile(posInHandSpace, tile):
			tilesInHand.remove_at(i)
			_putTileOnCursor(tile)
			return true
	return false

func _takeTileOffBoard(tile):
	tile.takeOffGrid()
	
	for i in range(validWords.size() - 1, -1, -1):
		var existingValidWord: ValidWord = validWords[i]
		if existingValidWord.tiles.find(tile) != -1:
			validWords.remove_at(i)
			existingValidWord.highlightSprite.queue_free()
	
	_checkValidWordFromTile($board.getTile(tile.gridX - 1, tile.gridY))
	_checkValidWordFromTile($board.getTile(tile.gridX + 1, tile.gridY))
	_checkValidWordFromTile($board.getTile(tile.gridX, tile.gridY - 1))
	_checkValidWordFromTile($board.getTile(tile.gridX, tile.gridY + 1))

func _checkBoardTileClicked(clickPos: Vector2) -> bool:
	var tile = $board.getTileAtBoardCoords(clickPos)
	if tile != null and tile.confirmed == false:
		_putTileOnCursor(tile)
		_takeTileOffBoard(tile)
		
		return true
	return false

func _dropCursorTile(clickPos: Vector2):
	if tileOnCursor != null:
		var posInHandSpace = clickPos - $hand.position
		if posInHandSpace.y < -tileHeight and $board.canPlaceTileAtBoardCoords(clickPos):
			var posInBoardSpace = clickPos - $board.position
			var displacedTile = $board.placeTileAtBoardCoords(tileOnCursor, clickPos)
			_checkValidWordFromTile(tileOnCursor)
			if displacedTile != null:
				addTileToHand(displacedTile)
			tileOnCursor = null
			return
		addTileToHand(tileOnCursor)
		tileOnCursor = null

func _addValidWord(newValidWord: ValidWord) -> bool:
	for existingValidWord:ValidWord in validWords + confirmedWords:
		var notIdentical = false
		for newTile in newValidWord.tiles:
			if existingValidWord.tiles.find(newTile) == -1:
				notIdentical = true
				break
		if notIdentical == false:
			return false
	
	for i in range(validWords.size() - 1, -1, -1):
		var existingValidWord: ValidWord = validWords[i]
		var keepExistingWord: bool
		for existingTile in existingValidWord.tiles:
			if newValidWord.tiles.find(existingTile) == -1:
				keepExistingWord = true
				break
		if keepExistingWord == false:
			validWords.remove_at(i)
			existingValidWord.highlightSprite.queue_free()
	validWords.append(newValidWord)
	return true

func _confirmWord(validWord:ValidWord):
	confirmedWords.append(validWord)
	for i in range(validWord.tiles.size()):
		if validWord.tiles[i].confirmed == false:
			validWord.tiles[i].confirm()
			drawRandomTile()

func _checkWordConfirmation(clickPos: Vector2):
	var tile = $board.getTileAtBoardCoords(clickPos)
	if tile != null:
		for i in range(validWords.size() - 1, -1, -1):
			var validWord:ValidWord = validWords[i]
			if validWord.tiles.find(tile) != -1:
				validWords.remove_at(i)
				validWord.highlightSprite.queue_free()
				_confirmWord(validWord)

func _checkValidWordFromTile(tile):
	if tile == null:
		return
	if tile.onGrid == false:
		return
	var horizontalTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, 1, 0)
	var verticalTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, 0, 1)
	
	if horizontalTiles.size() > 1 and verticalTiles.size() > 1:
		var horizontalWord = ValidWord.new(horizontalTiles)
		var verticalWord = ValidWord.new(verticalTiles)
		if $dictionary.getWordDefinitions(horizontalWord.word).size() > 0 and $dictionary.getWordDefinitions(verticalWord.word).size() > 0:
			if _addValidWord(horizontalWord):
				horizontalWord.highlightSprite = $board.highlightTiles(horizontalWord.tiles)
			if _addValidWord(verticalWord):
				verticalWord.highlightSprite = $board.highlightTiles(verticalWord.tiles)
	elif horizontalTiles.size() > 1:
		var horizontalWord = ValidWord.new(horizontalTiles)
		if $dictionary.getWordDefinitions(horizontalWord.word).size() > 0:
			if _addValidWord(horizontalWord):
				horizontalWord.highlightSprite = $board.highlightTiles(horizontalWord.tiles)
	elif verticalTiles.size() > 1:
		var verticalWord = ValidWord.new(verticalTiles)
		if $dictionary.getWordDefinitions(verticalWord.word).size() > 0:
			if _addValidWord(verticalWord):
				verticalWord.highlightSprite = $board.highlightTiles(verticalWord.tiles)

func _addTile(letter, score) -> Tile:
	var tile = tileTemplate.instantiate()
	tile.setStats(letter, score)
	add_child(tile)
	return tile

func _input(event):
	if event is InputEventMouseButton:
		var clickPos = _mousePosToLocalPos(event.position)
		if event.is_action_pressed("placeTile"):
			if doubleClickTimer > 0:
				_checkWordConfirmation(clickPos)
			else:
				startingClickPos = clickPos
				waitingForDragMovement = true
				doubleClickTimer = doubleClickTime
		elif event.is_action_released("placeTile"):
			waitingForDragMovement = false
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
