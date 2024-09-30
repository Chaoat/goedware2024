class_name PlayerController
extends Node

@export var worldReference : NPCSpawner
@export var boardReference : ScrabbleBoard
@export var handReference : Hand

const conversationReward:float = 100
const conversationFailureMalus:float = -50
const conversationWalkAwayDistance:float = 1
const conversationGap:float = 30

var playerReference : Player3D
var isInConversation : bool = false

var drink_timer : float = 0
@export var drink_duration : float = 8
var current_drink

var timerTillConversation:float = conversationGap

var wildcard_chance : int = 200 # Lower is less probable
var wildcard_count : int = 4 # Max wildcards per proc
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
	timerTillConversation = conversationGap
	isInConversation = true
	conversingNPC = npc
	startingPlayerPos = playerReference.position
	var spokenSentence:String = ""
	for i in range(npc.conversationDifficulty):
		var validWord = boardReference.randomlySelectDesiredWord()
		spokenSentence = spokenSentence + " " + validWord.word
	
	boardReference.speakSentence(spokenSentence, conversingNPC.NPC_id + 1)
	
	playerReference.lockCamera(npc.getFacePosition())

func _endConversation():
	isInConversation = false
	conversingNPC.talking = false
	Global.addConvincingness(conversationReward)
	for i in range(0,conversingNPC.conversationDifficulty + 1):
		boardReference.addWordToBoard(boardReference.find_child("dictionary").randomlyGenerateWord())
	
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

func _getRandomNPCBetweenDifficulties(minDifficulty:int, _maxDifficulty:int):
	var viableNPCs = []
	for npc:NPC in worldReference.npcList:
		if npc.conversationDifficulty >= minDifficulty and npc.conversationDifficulty <= minDifficulty:
			viableNPCs.append(npc)
	
	if viableNPCs.size() == 0:
		return null
	var index = randi()%viableNPCs.size()
	return viableNPCs[index]

var isGameRunning = true
func _process(delta: float) -> void:
	if isGameRunning:
		if isInConversation == false:
			for npc:NPC in worldReference.npcList:
				if npc.talking and npc.conversationDifficulty > 0 and boardReference.confirmedWords.size() >= npc.conversationDifficulty:
					_startConversation(npc)
				elif npc.talking:
					npc.talking = false
			
			if huntingNPC == null:
				if timerTillConversation > 0:
					timerTillConversation = timerTillConversation - delta
				else:
					huntingNPC = _getRandomNPCBetweenDifficulties(1, 9)
			else:
				huntingNPC.setNavTarget(playerReference.position)
				if huntingNPC.position.distance_to(playerReference.position) <= 1.5:
					huntingNPC.talking = true
					_startConversation(huntingNPC)
					huntingNPC = null
		else:
			if boardReference.areDesiresCleared():
				_endConversation()
			elif playerReference.position.distance_to(startingPlayerPos) > conversationWalkAwayDistance:
				_walkAwayFromConversation()
		
		if drink_timer:
			_handle_drinks(delta)
		
		leave_timer += delta
		if leave_timer > leave_freq:
			leave_timer = 0
			worldReference.force_leave()

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

func player_drank(drink):
	if drink_timer == 0:
		current_drink = drink
		handReference.player_drank(drink)
		drink_timer = drink_duration

func got_word(word):
	boardReference.addWordToBoard(word)
