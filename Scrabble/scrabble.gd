class_name ScrabbleBoard
extends Control

const dragDistanceToPickup:float = 15.0
const doubleClickTime:float = 0.2
const startingHandSize:int = 9

@export var tileTemplate : PackedScene
@export var success_reward : int = 10
var tileWidth = 0
var tileHeight = 0

var tileBag : TileBag
var tilesInHand = []
var tileOnCursor : Tile

var tilesSnakingOutMouth = []
var tilesSnakingPositions = []

# These are all arrays of valid words
var validWords = [] # Words that are valid on the board, but not yet confirmed
var confirmedWords = [] # Words that are confirmed and locked into the board
var desiredWords = [] # Words that need to be sent out of mouth (OVERLAPS WITH CONFIRMED WORDS)

var voices:Array = []

class ValidWord:
	func _init(inputTiles):
		tiles = inputTiles
		word = ""
		for tile in tiles:
			word = word + tile.letter
	
	func clearHighlightSprite():
		if highlightSprite != null:
			highlightSprite.queue_free()
			highlightSprite = null
	
	func getScore():
		var score = 0
		for tile:Tile in tiles:
			score = score + tile.score
		return score
	
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
		var _index = WordDictionary.letterToIndex(tile.letter)
		#tilesInBag[index] = tilesInBag[index] + 1
		#tilesLeft = tilesLeft + 1
	
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
					#tilesInBag[i] = tilesInBag[i] - 1
					break
				else:
					randomChoice = randomChoice - nLetters
			#tilesLeft = tilesLeft - 1
			return [letter, score]
		return []
	
	func getScoreForLetter(letter:String):
		if letter == "?":
			return 0
		var index = WordDictionary.letterToIndex(letter)
		return letterToScore[index]

func _initTileDimensions():
	var tempTile = tileTemplate.instantiate()
	for child in tempTile.get_children():
		if child is Sprite2D:
			tileWidth = max(tileWidth, ceil(child.get_transform().get_scale().x * child.get_rect().size.x))
			tileHeight = max(tileHeight, ceil(child.get_transform().get_scale().y * child.get_rect().size.y))
	#print("tile width: ",tileWidth," tile height: ",tileHeight)
	tempTile.queue_free()
	
	$board.initBoardDimensions(tileWidth, tileHeight)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initTileDimensions()
	tileBag = TileBag.new()
	for i in range(0,startingHandSize):
		drawRandomTile()
	
	addWordToBoard("party", 6)
	
	var systemVoices = DisplayServer.tts_get_voices_for_language("en")
	voices = []
	for i in range(20):
		var voiceI = randi()%systemVoices.size()
		var volume = 60 + 40*randf()
		var pitch = 0.3 + 1.5*randf()
		var rate = 0.4 + 0.6*randf()
		voices.append([systemVoices[voiceI], volume, pitch, rate])

func _updateHandTiles(_dt: float):
	var tileI = 0
	var nTiles = tilesInHand.size()
	#for tile:Tile in tilesInHand:
	for i in range(tilesInHand.size()):
		if is_instance_valid(tilesInHand[i]): # Checks that tile hasn't been freed
			var tile = tilesInHand[i]
			tile.targetPos.x = (tileI - (nTiles - 1)/2.0)*tileWidth
			tile.targetPos.y = 0
			tileI = tileI + 1

func _updateTileOnCursor(_dt: float):
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

func _updateSnakingTiles(_dt: float):
	for i in range(tilesSnakingOutMouth.size() - 1, -1, -1):
		var tile:Tile = tilesSnakingOutMouth[i]
		tile.targetPos = tilesSnakingPositions[i]
		if i == 0 and tile.position.distance_to(tile.targetPos) <= 1:
			$click2.play()
			tilesSnakingOutMouth.remove_at(i)
			tile.queue_free()

func _mousePosToLocalPos(pos: Vector2):
	return pos - global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float) -> void:
	_updateHandTiles(dt)
	_updateTileOnCursor(dt)
	_updateMouseMovement(dt)
	_updateSnakingTiles(dt)
	
	for i in range(desiredWords.size() - 1, -1, -1):
		if confirmedWords.find(desiredWords[i]) == -1:
			desiredWords.remove_at(i)

func _putTileOnCursor(tile: Tile):
	tileOnCursor = tile
	tileOnCursor.localPositionLerpMult = 3
	tile.reparent(self)
	#add_child(tile)

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

func _takeTileOffBoard(tile:Tile):
	for i in range(confirmedWords.size() - 1, -1, -1):
		var existingValidWord: ValidWord = confirmedWords[i]
		if existingValidWord.tiles.find(tile) != -1:
			confirmedWords.remove_at(i)
			existingValidWord.clearHighlightSprite()

	for i in range(validWords.size() - 1, -1, -1):
		var existingValidWord: ValidWord = validWords[i]
		if existingValidWord.tiles.find(tile) != -1:
			validWords.remove_at(i)
			existingValidWord.clearHighlightSprite()
	
	tile.takeOffGrid()
	
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
			#var posInBoardSpace = clickPos - $board.position
			var displacedTile = $board.placeTileAtBoardCoords(tileOnCursor, clickPos)
			_checkValidWordFromTile(tileOnCursor)
			if displacedTile != null:
				for i in range(validWords.size() - 1, -1, -1):
					if validWords[i].tiles.find(displacedTile) != -1:
						validWords[i].clearHighlightSprite()
						validWords.remove_at(i)
				addTileToHand(displacedTile)
			tileOnCursor.localPositionLerpMult = 1
			tileOnCursor = null
			return
		addTileToHand(tileOnCursor)
		tileOnCursor.localPositionLerpMult = 1
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
			existingValidWord.clearHighlightSprite()
	validWords.append(newValidWord)
	return true

func _snakeIntoMouth(tile:Tile):
	if tilesSnakingOutMouth.is_empty():
		tilesSnakingPositions.clear()
	tilesSnakingPositions.append(tile.position)
	tile.localPositionLerpMult = 2
	tilesSnakingOutMouth.append(tile)
	_takeTileOffBoard(tile)

func _checkDesiredWordDone(desiredWord:ValidWord) -> bool:
	var endzoneTiles = $board.getTilesInEndzone()
	for tile:Tile in endzoneTiles:
		var tiles:Array = $board.pathfindBetweenTiles(tile, desiredWord.tiles[0])
		if tiles.is_empty() == false:
			var spokenWords:Array = []
			for pathTile in tiles:
				if pathTile.onGrid:
					for i in range(confirmedWords.size() - 1, -1, -1):
						var validWord:ValidWord = confirmedWords[i]
						if spokenWords.find(validWord) == -1:
							if validWord.tiles.find(pathTile) != -1:
								spokenWords.append(validWord)
					
					var isDesiredWord = false
					for i in range(desiredWords.size() - 1, -1, -1):
						var checkingDesiredWord:ValidWord = desiredWords[i]
						if checkingDesiredWord.tiles.find(pathTile) != -1:
							isDesiredWord = true
							for desiredTile in checkingDesiredWord.tiles:
								if desiredTile.onGrid:
									_snakeIntoMouth(desiredTile)
							desiredWords.remove_at(i)
							#$snake.play()
					
					if isDesiredWord == false:
						_snakeIntoMouth(pathTile)
			
			var speak:String = ""
			for validWord:ValidWord in spokenWords:
				speak = speak + validWord.word + " "
			speakSentence(speak, 0)
			return true
	return false

func _checkDesiredWordOnPosition(clickPos: Vector2):
	var tile = $board.getTileAtBoardCoords(clickPos)
	for desiredWord:ValidWord in desiredWords:
		if desiredWord.tiles.find(tile) != -1:
			_checkDesiredWordDone(desiredWord)

func _confirmWord(validWord:ValidWord, drawTiles:bool):
	for i in range(confirmedWords.size() - 1, -1, -1):
		var shouldRemove = true
		for tile in confirmedWords[i].tiles:
			if validWord.tiles.find(tile) == -1:
				shouldRemove = false
				break
		if shouldRemove:
			var desiredIndex = desiredWords.find(confirmedWords[i])
			if desiredIndex != -1:
				desiredWords[desiredIndex].clearHighlightSprite()
				desiredWords.remove_at(desiredIndex)
			confirmedWords.remove_at(i)
	
	confirmedWords.append(validWord) # Confirming happens here
	$confirm.play()
	for i in range(validWord.tiles.size()):
		if validWord.tiles[i].confirmed == false:
			validWord.tiles[i].confirm()
			if drawTiles:
				drawRandomTile()
	
	var oldValidWords = validWords.duplicate()
	for i in range(validWords.size() - 1, -1, -1):
		validWords[i].clearHighlightSprite()
		validWords.remove_at(i)
	
	for oldValidWord in oldValidWords:
		for tile in oldValidWord.tiles:
			if tile.confirmed == false:
				_checkValidWordFromTile(tile)
	
	#for i in range(validWords.size()):
		#if validWords[i] == validWord:
			#validWords.remove_at(i)

func _checkWordConfirmation(clickPos: Vector2):
	var tile = $board.getTileAtBoardCoords(clickPos)
	if tile != null:
		for i in range(validWords.size() - 1, -1, -1):
			var validWord:ValidWord = validWords[i]
			if validWord.tiles.find(tile) != -1:
				validWords.remove_at(i)
				validWord.clearHighlightSprite()
				if validWord.word.find("?") != -1:
					var possibleWords = $dictionary.getWordDefinitions(validWord.word)
					var chosenWord = possibleWords[randi()%possibleWords.size()]
					validWord.word = chosenWord
					for j in range(validWord.tiles.size()):
						if validWord.tiles[j].letter == "?":
							var wildTile = validWord.tiles[j]
							wildTile.setStats(validWord.word[j], 0)
				Global.addConvincingness(2*validWord.getScore())
				_confirmWord(validWord, true)
				return

func _areLettersBreakingOtherWords(tiles:Array, dirX:int, dirY:int) -> bool:
	for tile:Tile in tiles:
		var perpTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, dirX, dirY, true)
		if perpTiles.size() > 1:
			var word = ""
			for perpTile in perpTiles:
				word = word + perpTile.letter
			if $dictionary.getWordDefinitions(word).size() == 0:
				return true
	
	return false

func _checkValidWordFromTile(tile):
	if tile == null:
		return
	if tile.onGrid == false:
		return
	var horizontalTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, 1, 0, false)
	var verticalTiles = $board.getContiguousTiles(tile.gridX, tile.gridY, 0, 1, false)
	
	var horizontalWord = ValidWord.new(horizontalTiles)
	var verticalWord = ValidWord.new(verticalTiles)
	var horizontalSatisfied = horizontalTiles.size() == 1 or ($dictionary.getWordDefinitions(horizontalWord.word).size() > 0 and _areLettersBreakingOtherWords(horizontalTiles, 0, 1) == false)
	var verticalSatisfied = verticalTiles.size() == 1 or ($dictionary.getWordDefinitions(verticalWord.word).size() > 0 and _areLettersBreakingOtherWords(verticalTiles, 1, 0) == false)
	
	if horizontalSatisfied and horizontalTiles.size() > 1:
		if _addValidWord(horizontalWord):
			horizontalWord.highlightSprite = $board.highlightTiles(horizontalWord.tiles, Vector4(0.66, 0.33, 1.0, 1.0))
	if verticalSatisfied and verticalTiles.size() > 1:
		if _addValidWord(verticalWord):
			verticalWord.highlightSprite = $board.highlightTiles(verticalWord.tiles, Vector4(0.66, 0.33, 1.0, 1.0))

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
				_checkDesiredWordOnPosition(clickPos)
			else:
				startingClickPos = clickPos
				waitingForDragMovement = true
				doubleClickTimer = doubleClickTime
		elif event.is_action_released("placeTile"):
			waitingForDragMovement = false
			_dropCursorTile(clickPos)

func _placeWord(word:String, x:int, y:int, xDir:int, yDir:int) -> ValidWord:
	var tiles = []
	for letter in word:
		var newTile:Tile = _addTile(letter, tileBag.getScoreForLetter(letter))
		var displacedTile = $board.placeTile(newTile, x, y)
		if displacedTile != null:
			addTileToHand(displacedTile)
		x = x + xDir
		y = y + yDir
		tiles.append(newTile)
	return ValidWord.new(tiles)

func speakSentence(string:String, voiceID:int, volumeMod:float = 1.0):
	voiceID = voiceID%voices.size()
	var voice = voices[voiceID]
	DisplayServer.tts_speak(string, voice[0], volumeMod*voice[1], voice[2], voice[3])

func addWildtile():
	var validTiles:Array = $board.getValidTilesForWord("?")
	if validTiles.size() > 0:
		var index = randi()%validTiles.size()
		var validTile = validTiles[index]
		var newTile:Tile = _addTile("?", 0)
		var displacedTile = $board.placeTile(newTile, validTile[0], validTile[1])
		if displacedTile != null:
			addTileToHand(displacedTile)
		newTile.confirmed = true

func addWordToBoard(word:String, maxX:int = 999) -> bool:
	var validTiles:Array = $board.getValidTilesForWord(word, maxX)
	if validTiles.size() > 0:
		var index = randi()%validTiles.size()
		var validTile = validTiles[index]
		_confirmWord(_placeWord(word, validTile[0], validTile[1], (validTile[2] + 1)%2, validTile[2]), false)
		return true
	else:
		return false

func addTileToHand(tile: Tile) -> Tile:
	tile.reparent($hand)
	
	var handIndex = ceil((tilesInHand.size() - 1)/2 + tile.position.x/tileWidth)
	handIndex = max(min(handIndex, tilesInHand.size()), 0)
	#print(handIndex)
	tilesInHand.insert(handIndex, tile)
	
	return tile

func drawRandomTile() -> Tile:
	$draw.play()
	var tileStats = tileBag.pullTile()
	if tileStats.is_empty():
		return null
	return addTileToHand(_addTile(tileStats[0], tileStats[1]))
	
func clearClutter() -> void:
	for x in range($board.boardWidth):
		for y in range($board.boardHeight):
			var tile:Tile = $board.boardArray[x][y]
			if tile != null and tile.onGrid and tile.confirmed:
				var clutter = true
				for word in confirmedWords:
					if word.tiles.find(tile) != -1:
						clutter = false
				
				if clutter:
					for i in range(validWords.size() - 1, -1, -1):
						if validWords[i].tiles.find(tile) != -1:
							validWords[i].clearHighlightSprite()
							validWords.remove_at(i)
					#_snakeIntoMouth(tile) # This is kind of a cool effect
					tile.queue_free() # Maybe a nice particle effect to make it look like you're vomiting
				
func redraw() -> void:
	$multi.play()
	var discard : int = 0
	for tile in tilesInHand:
		tile.queue_free()
		discard += 1
	tilesInHand.clear()
	for i in discard:
		drawRandomTile()
	
	
func rotate() -> void:
	tilesInHand.pop_back().queue_free()
	drawRandomTile()
	
func randomClutter() -> void:
	$multi.play()
	for x in range($board.boardWidth):
		for y in range($board.boardHeight):
			var tile:Tile = $board.boardArray[x][y]
			if tile != null and tile.onGrid:
				# <<<This instead if you only wanted it to affect clutter
				var clutter = true
				for word in confirmedWords:
					if word.tiles.find(tile) != -1:
						clutter = false
				if clutter:
					var tileStats = tileBag.pullTile()
					tile.setStats(tileStats[0], tileStats[1])
				#var tileStats = tileBag.pullTile()
				#tile.setStats(tileStats[0], tileStats[1])
	

func selectDesiredWord(word:String) -> ValidWord:
	for validWord:ValidWord in confirmedWords:
		if validWord.word == word:
			desiredWords.append(validWord)
			validWord.highlightSprite = $board.highlightTiles(validWord.tiles, Vector4(0.2, 0.8, 1.0, 1.0))
			return validWord
	return null

func randomlySelectDesiredWord() -> ValidWord:
	if desiredWords.size() >= confirmedWords.size():
		return null
	var index = randi()%confirmedWords.size()
	var validChoice = false
	while validChoice == false:
		validChoice = true
		for word in desiredWords:
			if confirmedWords[index] == word:
				validChoice = false
				index = randi()%confirmedWords.size()
				break
				
	desiredWords.append(confirmedWords[index])
	confirmedWords[index].highlightSprite = $board.highlightTiles(confirmedWords[index].tiles, Vector4(0.2, 0.8, 1.0, 1.0))
	return confirmedWords[index]

func areDesiresCleared() -> bool:
	return desiredWords.size() == 0

func clearDesires():
	for i in range(desiredWords.size() - 1, -1, -1):
		desiredWords[i].clearHighlightSprite()
		desiredWords.remove_at(i)

func wildSpray(n):
	for i in n:
		addWildtile()
		$multi.play()
