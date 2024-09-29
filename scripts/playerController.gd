extends Node

@export var worldReference : NPCSpawner
@export var boardReference : ScrabbleBoard
@export var handReference : Hand

var playerReference : Player3D
var isInConversation : bool = false

var drink_timer : float = 0
@export var drink_duration : float = 5
var current_drink

var wildcard_chance : int = 200 # Lower is less probable
var wildcard_count : int = 4 # Max wildcards per proc

func _ready() -> void:
	playerReference = worldReference.find_child("Player")
	playerReference.drinking.connect(player_drank)

var conversingNPC:NPC = null
func _startConversation(npc:NPC):
	isInConversation = true
	conversingNPC = npc
	playerReference.lockMovement(true)
	for i in range(npc.conversationDifficulty):
		boardReference.randomlySelectDesiredWord()

func _endConversation():
	isInConversation = false
	conversingNPC.talking = false
	playerReference.lockMovement(false)
	for i in range(0,conversingNPC.conversationDifficulty + 1):
		boardReference.addWordToBoard(boardReference.find_child("dictionary").randomlyGenerateWord())

func _process(delta: float) -> void:
	if isInConversation == false:
		for npc:NPC in worldReference.npcList:
			if npc.talking and npc.conversationDifficulty > 0 and boardReference.confirmedWords.size() >= npc.conversationDifficulty:
				_startConversation(npc)
			elif npc.talking:
				npc.talking = false
	else:
		if boardReference.areDesiresCleared():
			_endConversation()
			
	if drink_timer:
		drink_timer -= delta
		if drink_timer <=0:
			drink_timer = 0
			handReference.finish_drink()
			current_drink = null
		else:
			match current_drink:
				0:
					print('hand size')
					boardReference.drawRandomTile()
					current_drink = null
				1:
					if randi() % wildcard_chance == 0:
						print('wilding')
						for i in (randi() % wildcard_count + 1):
							boardReference.addWildtile()
							

			
func player_drank(drink):
	if drink_timer == 0:
		current_drink = drink
		handReference.player_drank(drink)
		drink_timer = drink_duration
