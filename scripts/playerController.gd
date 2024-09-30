class_name PlayerController
extends Node

@export var worldReference : NPCSpawner
@export var boardReference : ScrabbleBoard
@export var handReference : Hand
@export var moreWordsNeededLabel : Label

@export var winScreen : TextureRect
@export var loseScreen : TextureRect

const conversationReward:float = 100
const conversationFailureMalus:float = -50
const conversationWalkAwayDistance:float = 1
const conversationGap:float = 30

var playerReference : Player3D
var isInConversation : bool = false

var drink_timer : float = 0
var drink_duration : float = 20
var current_drink

var timerTillConversation:float = conversationGap

var wildcard_chance : int = 200 # Lower is less probable
var wildcard_count : int = 1 # Max wildcards per proc
var rotate_freq : float = 1 # Seconds between rotation
var rotate_timer: float = 0

var leave_timer : float = 0
var leave_freq : float = 60

var huntingNPC:NPC
var conversingNPC:NPC = null
var startingPlayerPos:Vector3

func _ready() -> void:
	playerReference = worldReference.find_child("Player")
	playerReference.drinking.connect(player_drank)
	playerReference.interact.connect(got_word)

func _startConversation(npc:NPC):
	playerReference.interruptMovement = true
	timerTillConversation = conversationGap
	isInConversation = true
	conversingNPC = npc
	startingPlayerPos = playerReference.position
	var spokenSentence:String = ""
	for i in range(npc.conversationDifficulty):
		var validWord = boardReference.randomlySelectDesiredWord()
		spokenSentence = spokenSentence + " " + validWord.word
	
	DisplayServer.tts_stop()
	boardReference.speakSentence(spokenSentence, conversingNPC.NPC_id + 1)
	
	playerReference.lockCamera(npc.getFacePosition())

func _endConversation():
	isInConversation = false
	conversingNPC.talking = false
	conversingNPC.waitTime = 5.0
	conversingNPC.conversationWon = true
	Global.addConvincingness(conversationReward)
	var sentence = ""
	for i in range(0,conversingNPC.conversationDifficulty + 1):
		var word = boardReference.find_child("dictionary").randomlyGenerateWord()
		boardReference.addWordToBoard(word)
		sentence = sentence + " " + word
	boardReference.speakSentence(sentence, conversingNPC.NPC_id + 1)
	
	if worldReference.npcList.size() == 1:
		worldReference.force_leave()
	
	playerReference.unlockCamera()

func _walkAwayFromConversation():
	isInConversation = false
	conversingNPC.talking = false
	Global.addConvincingness(conversationFailureMalus)
	boardReference.clearDesires()
	$leave.play()
	playerReference.unlockCamera()

func _physics_process(delta):
	if isInConversation:
		var distFromStart = playerReference.position.distance_to(startingPlayerPos)
		playerReference.position = playerReference.position.move_toward(startingPlayerPos, 0.012*playerReference.speed*delta*pow(distFromStart/conversationWalkAwayDistance, 2))

func _getRandomNPCBetweenDifficulties(minDifficulty:int):
	var viableNPCs = []
	for npc:NPC in worldReference.npcList:
		if npc.conversationDifficulty >= minDifficulty:
			viableNPCs.append(npc)
	
	if viableNPCs.size() == 0:
		return null
	var index = randi()%viableNPCs.size()
	return viableNPCs[index]

var randomSpeechTime = 5.0
var huntingTime = 0.0
var moreWordsNeededWarning = 0.0
var isGameRunning = true
var ScreenModulate = 0
var lose = false
var win = false

func _process(delta: float) -> void:
	if isGameRunning:
		if not isInConversation:
			leave_timer += delta
			for npc:NPC in worldReference.npcList:
				if npc.talking and npc.conversationDifficulty > 0:
					if boardReference.confirmedWords.size() >= npc.conversationDifficulty:
						_startConversation(npc)
					else:
						moreWordsNeededWarning = 3.0
						npc.talking = false
				elif npc.talking:
					npc.talking = false
			
			if huntingNPC == null:
				if timerTillConversation > 0:
					timerTillConversation = timerTillConversation - delta
				else:
					huntingNPC = _getRandomNPCBetweenDifficulties(1)
					huntingTime = 10.0
			else:
				huntingTime = huntingTime - delta
				if huntingTime <= 0:
					huntingNPC = null
				elif huntingNPC.conversationDifficulty > boardReference.confirmedWords.size():
					huntingNPC = null
				else:
					huntingNPC.setNavTarget(playerReference.position)
					if huntingNPC.position.distance_to(playerReference.position) <= 1.5:
						huntingNPC.talking = true
						_startConversation(huntingNPC)
						huntingNPC = null
						
			randomSpeechTime = randomSpeechTime - delta
			if randomSpeechTime < 0.0 and DisplayServer.tts_is_speaking() == false:
				randomSpeechTime = randomSpeechTime + 2 + 4*randf()
				_randomBackgroundNoise()
		else:
			leave_timer += delta
			if boardReference.areDesiresCleared():
				_endConversation()
			elif playerReference.position.distance_to(startingPlayerPos) > conversationWalkAwayDistance:
				_walkAwayFromConversation()
		
		if drink_timer:
			_handle_drinks(delta)
		
		if leave_timer > leave_freq:
			leave_timer = 0
			worldReference.force_leave()
		
		if worldReference.npcList.size() == 0:
			win = true
			isGameRunning = false
			playerReference.speed = 0
			playerReference.rotation_speed = 0
			winScreen.visible = true
		
		if Global.convincingness <= 0:
			lose = true
			isGameRunning = false
			playerReference.speed = 0
			playerReference.rotation_speed = 0
			loseScreen.visible = true
	
	if moreWordsNeededWarning > 0:
		moreWordsNeededLabel.visible = true
		moreWordsNeededWarning = moreWordsNeededWarning - delta
	else:
		moreWordsNeededLabel.visible = false
		
	if lose:
		_addModulate(delta)
		loseScreen.modulate = Color(1, 1, 1, ScreenModulate)
	elif win:
		_addModulate(delta)
		winScreen.modulate = Color(1, 1, 1, ScreenModulate)
	
	if Input.is_action_just_pressed("Restart"):
		get_tree().change_scene_to_file("res://scenes/gameWithFakeout.tscn")
		Global.addConvincingness(9999)
		Global.skipIntro = true

func _randomBackgroundNoise():
	var speakingNPC:NPC = _getRandomNPCBetweenDifficulties(0)
	if speakingNPC != null:
		var distance = playerReference.position.distance_to(speakingNPC.position)
		var volume = max(1 - pow(distance, 2)/100, 0.2)
		
		var randomSentence = ""
		for i in range(speakingNPC.conversationDifficulty):
			var word = boardReference.find_child("dictionary").randomlyGenerateWord()
			randomSentence = randomSentence + " " + word
		boardReference.speakSentence(randomSentence, speakingNPC.NPC_id + 1, volume)

func _handle_drinks(delta):
	drink_timer -= delta
	if drink_timer <=0:
		drink_timer = 0
		handReference.finish_drink()
		current_drink = null
	else:
		match current_drink:
			0:
				#print('hand size')
				boardReference.drawRandomTile()
				current_drink = null
			1:
				if randi() % wildcard_chance == 0:
					#print('wilding')
					boardReference.wildSpray(randi() % wildcard_count + 1)
							
			2:
				#print('head empty')
				boardReference.clearClutter()
				current_drink = null
					
			3:
				#print('go again')
				boardReference.redraw()
				current_drink = null
					
			4:
				rotate_timer += delta
				if rotate_timer > rotate_freq:
					rotate_timer = 0
					#print('revolving door')
					boardReference.rotate()
						
			5:
				#print('trippy')
				boardReference.randomClutter()
				current_drink = null

func startMusic():
	$music.find_child("musicIntro").playing = true

func player_drank(drink):
	if drink_timer == 0:
		current_drink = drink
		handReference.player_drank(drink)
		drink_timer = drink_duration

func got_word(word):
	boardReference.addWordToBoard(word)

func _addModulate(delta):
	if ScreenModulate != 1:
		ScreenModulate += delta/3
		if ScreenModulate > 1:
			ScreenModulate = 1
